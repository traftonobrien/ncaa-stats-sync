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

.fetch_single_team_stats <- function(team_info, year, type, season_ids) {
  team_id <- as.integer(team_info$team_id[[1]])
  team_name <- as.character(team_info$team_name[[1]])
  category_id <- ncaa_get_category_id(season_ids, year, type)
  url <- ncaa_stats_url(team_id, category_id)

  fetch_result <- ncaa_fetch_page(url)
  if (!identical(fetch_result$status, "success")) {
    return(list(
      ok = FALSE,
      status = fetch_result$status,
      team_id = team_id,
      team_name = team_name,
      rows = NULL,
      detail = fetch_result$error %||% "fetch error"
    ))
  }

  parsed <- ncaa_parse_stats_html(fetch_result$html, type)
  if (!identical(parsed$status, "success")) {
    return(list(
      ok = FALSE,
      status = parsed$status,
      team_id = team_id,
      team_name = team_name,
      rows = NULL,
      detail = parsed$detail %||% parsed$status
    ))
  }

  team_rows <- tryCatch(
    if (type == "pitching") {
      extract_pitching_rows(parsed$df, parsed$links, team_info)
    } else {
      extract_batting_rows(parsed$df, parsed$links, team_info)
    },
    error = function(e) NULL
  )

  if (is.null(team_rows) || nrow(team_rows) == 0) {
    return(list(
      ok = FALSE,
      status = "parse_failed",
      team_id = team_id,
      team_name = team_name,
      rows = NULL,
      detail = "Row extraction produced empty result"
    ))
  }

  if (type == "pitching") {
    team_rows <- add_pitching_derived_metrics(team_rows)
  } else {
    team_rows <- add_batting_derived_metrics(team_rows)
  }

  list(
    ok = TRUE,
    status = "success",
    team_id = team_id,
    team_name = team_name,
    rows = team_rows,
    detail = NULL
  )
}

ncaa_sync_type <- function(year, type, cfg, mode = cfg$mode %||% "incremental", team_name = NULL, limit = NULL) {
  season_ids <- .ncaa_season_ids()
  all_teams <- collegebaseball::ncaa_teams(years = year, divisions = cfg$division) |>
    dplyr::arrange(.data$team_name)

  if (!is.null(team_name) && nzchar(team_name)) {
    pattern <- stringr::regex(team_name, ignore_case = TRUE)
    all_teams <- dplyr::filter(all_teams, stringr::str_detect(.data$team_name, pattern))
  } else if (identical(mode, "incremental")) {
    all_teams <- ncaa_build_incremental_teams(all_teams, cfg$output_dir, cfg$watch_list, year)
  }

  if (!is.null(limit)) all_teams <- utils::head(all_teams, as.integer(limit))

  message(sprintf("[%s %s] %s mode: processing %d team(s)", year, type, mode, nrow(all_teams)))

  rows <- list()
  outcome_counts <- list(success = 0L, empty_stats = 0L, access_denied = 0L, parse_failed = 0L)
  failures <- list()

  for (i in seq_len(nrow(all_teams))) {
    team_info <- all_teams[i, , drop = FALSE]
    label <- as.character(all_teams$team_name[[i]])
    message(sprintf("[%s %s] %d/%d %s", year, type, i, nrow(all_teams), label))

    result <- tryCatch(
      .fetch_single_team_stats(team_info, year, type, season_ids),
      error = function(e) list(
        ok = FALSE,
        status = "parse_failed",
        team_id = as.integer(team_info$team_id[[1]]),
        team_name = label,
        rows = NULL,
        detail = conditionMessage(e)
      )
    )

    status_key <- result$status %||% "parse_failed"
    outcome_counts[[status_key]] <- (outcome_counts[[status_key]] %||% 0L) + 1L

    if (isTRUE(result$ok)) {
      rows[[length(rows) + 1]] <- result$rows
    } else {
      failures[[length(failures) + 1]] <- list(
        team_id = result$team_id,
        team_name = result$team_name,
        status = result$status,
        detail = result$detail
      )
      message(sprintf("  [%s] %s: %s", result$status, label, result$detail %||% ""))
    }

    if (i < nrow(all_teams)) Sys.sleep(0.15)
  }

  combined <- dplyr::bind_rows(rows)
  message(sprintf(
    "[%s %s] done: success=%d empty_stats=%d access_denied=%d parse_failed=%d rows=%d",
    year, type,
    outcome_counts$success %||% 0L,
    outcome_counts$empty_stats %||% 0L,
    outcome_counts$access_denied %||% 0L,
    outcome_counts$parse_failed %||% 0L,
    nrow(combined)
  ))

  list(
    rows = combined,
    outcome_counts = outcome_counts,
    failures = failures,
    team_count = nrow(all_teams)
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
    schema_version = cfg$schema_version %||% "1.0",
    division = cfg$division,
    years = cfg$years,
    types = cfg$types,
    mode = cfg$mode,
    write_team_stats = isTRUE(cfg$write_team_stats),
    results = list()
  )

  for (year in cfg$years) {
    pitch_df <- NULL
    bat_df <- NULL

    for (stat_type in cfg$types) {
      result <- ncaa_sync_type(year, stat_type, cfg, cfg$mode, team_name, limit)
      rows <- result$rows
      if (stat_type == "pitching") pitch_df <- rows
      if (stat_type == "batting") bat_df <- rows

      out_path <- file.path(cfg$output_dir, sprintf("%s-%s.json", stat_type, year))
      writeLines(
        jsonlite::toJSON(rows, dataframe = "rows", auto_unbox = TRUE, na = "null"),
        out_path,
        useBytes = TRUE
      )
      message(sprintf("Wrote %s (%d rows)", out_path, nrow(rows)))

      result_key <- sprintf("%s-%s", year, stat_type)
      meta$results[[result_key]] <- list(
        row_count = nrow(rows),
        team_count = result$team_count,
        outcome_counts = result$outcome_counts,
        failure_count = length(result$failures),
        failures = result$failures
      )
    }

    if (isTRUE(cfg$write_team_stats)) {
      min_ip <- cfg$min_ip_qualified %||% 5
      min_pa <- cfg$min_pa_qualified %||% 15
      engine <- ncaa_build_team_stat_engine(pitch_df, bat_df, min_ip, min_pa)
      team_path <- file.path(cfg$output_dir, sprintf("teams-%s.json", year))
      writeLines(
        jsonlite::toJSON(
          list(
            schema_version = cfg$schema_version %||% "1.0",
            year = year,
            division = cfg$division,
            engine
          ),
          auto_unbox = TRUE,
          na = "null",
          pretty = FALSE
        ),
        team_path,
        useBytes = TRUE
      )
      message(sprintf("Wrote %s", team_path))
      meta$results[[sprintf("%s-teams", year)]] <- list(
        path = basename(team_path),
        pitching_team_count = nrow(engine$pitching_teams),
        batting_team_count = nrow(engine$batting_teams)
      )
    }
  }

  writeLines(
    jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE, na = "null"),
    file.path(cfg$output_dir, "meta.json"),
    useBytes = TRUE
  )
  message(sprintf("Wrote %s", file.path(cfg$output_dir, "meta.json")))

  invisible(meta)
}
