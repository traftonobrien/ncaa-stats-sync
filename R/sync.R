ncaa_get_category_id <- function(season_ids, year, type) {
  year_row <- season_ids[season_ids$season == year, ]
  if (nrow(year_row) == 0) stop(sprintf("No NCAA season ids found for year %s", year))
  if (identical(type, "pitching")) return(year_row$pitching_id[[1]])
  if (identical(type, "batting")) return(year_row$batting_id[[1]])
  stop(sprintf("Unknown type: %s", type))
}

ncaa_build_incremental_teams <- function(all_teams, out_dir, watch_list = character(0), year = 2026L) {
  known_ids <- character(0)

  for (stat_type in c("pitching", "batting")) {
    p <- file.path(out_dir, sprintf("%s-%s.json", stat_type, year))
    if (!file.exists(p)) next
    rows <- tryCatch(jsonlite::fromJSON(p, simplifyDataFrame = TRUE), error = function(e) NULL)
    if (!is.null(rows) && nrow(rows) > 0 && "team_id" %in% names(rows)) {
      known_ids <- union(known_ids, as.character(rows$team_id))
    }
  }

  for (wt in watch_list) {
    matched <- all_teams[grepl(wt, all_teams$team_name, ignore.case = TRUE), ]
    if (nrow(matched) > 0) {
      known_ids <- union(known_ids, as.character(matched$team_id))
    }
  }

  if (length(known_ids) == 0) return(all_teams)
  all_teams[as.character(all_teams$team_id) %in% known_ids, , drop = FALSE]
}

ncaa_sync_type <- function(year, type, cfg, mode = cfg$mode %||% "incremental", team_name = NULL, limit = NULL) {
  season_ids <- baseballr:::rds_from_url(
    "https://raw.githubusercontent.com/robert-frey/college-baseball/main/ncaa_season_ids.rds"
  )
  category_id <- ncaa_get_category_id(season_ids, year, type)

  teams <- collegebaseball::ncaa_teams(years = year, divisions = cfg$division) |>
    dplyr::arrange(.data$team_name)

  if (!is.null(team_name) && nzchar(team_name)) {
    teams <- dplyr::filter(teams, stringr::str_detect(.data$team_name, stringr::regex(team_name, ignore_case = TRUE)))
  } else if (identical(mode, "incremental")) {
    teams <- ncaa_build_incremental_teams(teams, cfg$output_dir, cfg$watch_list, year)
  }

  if (!is.null(limit)) teams <- utils::head(teams, as.integer(limit))

  rows <- list()
  failures <- list()
  outcomes <- list(success = 0L, access_denied = 0L, empty_stats = 0L, parse_failed = 0L)

  for (i in seq_len(nrow(teams))) {
    team_info <- teams[i, , drop = FALSE]
    url <- ncaa_stats_url(team_info$team_id[[1]], category_id)
    fetch_result <- ncaa_fetch_page(url, cfg$max_wait_seconds, cfg$max_retries)

    if (!identical(fetch_result$status, "success")) {
      outcomes[[fetch_result$status]] <- (outcomes[[fetch_result$status]] %||% 0L) + 1L
      failures[[length(failures) + 1]] <- list(
        team_id = team_info$team_id[[1]],
        team_name = team_info$team_name[[1]],
        status = fetch_result$status,
        detail = fetch_result$error %||% "fetch error"
      )
      next
    }

    parsed <- ncaa_parse_stats_html(fetch_result$html, type)
    if (!identical(parsed$status, "success")) {
      outcomes[[parsed$status]] <- (outcomes[[parsed$status]] %||% 0L) + 1L
      failures[[length(failures) + 1]] <- list(
        team_id = team_info$team_id[[1]],
        team_name = team_info$team_name[[1]],
        status = parsed$status,
        detail = parsed$detail %||% "parse error"
      )
      next
    }

    normalized <- ncaa_normalize_rows(parsed$df, team_info, year, type)
    rows[[length(rows) + 1]] <- normalized
    outcomes$success <- outcomes$success + 1L
    Sys.sleep(0.15)
  }

  combined <- dplyr::bind_rows(rows)
  list(
    rows = combined,
    failures = failures,
    outcomes = outcomes,
    team_count = nrow(teams)
  )
}

ncaa_sync_daily <- function(config_path = NULL, mode = NULL, team_name = NULL, limit = NULL) {
  cfg <- ncaa_load_config(config_path)
  if (!is.null(mode)) cfg$mode <- mode

  dir.create(cfg$output_dir, recursive = TRUE, showWarnings = FALSE)
  on.exit(.ncaa_close_session(), add = TRUE)

  meta <- list(
    synced_at = format(Sys.time(), tz = "UTC", usetz = TRUE),
    source = "ncaaStatsSync",
    division = cfg$division,
    years = cfg$years,
    types = cfg$types,
    mode = cfg$mode,
    results = list()
  )

  for (year in cfg$years) {
    for (stat_type in cfg$types) {
      result <- ncaa_sync_type(year, stat_type, cfg, cfg$mode, team_name, limit)
      file_path <- file.path(cfg$output_dir, sprintf("%s-%s.json", stat_type, year))
      writeLines(
        jsonlite::toJSON(result$rows, dataframe = "rows", auto_unbox = TRUE, na = "null"),
        file_path,
        useBytes = TRUE
      )

      result_key <- sprintf("%s-%s", year, stat_type)
      meta$results[[result_key]] <- list(
        row_count = nrow(result$rows),
        team_count = result$team_count,
        outcome_counts = result$outcomes,
        failure_count = length(result$failures),
        failures = result$failures
      )
    }
  }

  writeLines(
    jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE, na = "null"),
    file.path(cfg$output_dir, "meta.json"),
    useBytes = TRUE
  )

  invisible(meta)
}
