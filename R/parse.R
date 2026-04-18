ncaa_parse_stats_html <- function(html, type = c("pitching", "batting")) {
  type <- match.arg(type)
  if (is.null(html) || !nzchar(html)) {
    return(list(status = "parse_failed", detail = "Empty HTML", df = NULL, links = character(0)))
  }

  doc <- tryCatch(xml2::read_html(html), error = function(e) NULL)
  if (is.null(doc)) {
    return(list(status = "parse_failed", detail = "Invalid HTML document", df = NULL, links = character(0)))
  }

  tables <- rvest::html_elements(doc, "table")
  if (length(tables) < 2) {
    return(list(status = "empty_stats", detail = "No stats table found", df = NULL, links = character(0)))
  }

  stat_table <- tables[[2]]
  parsed <- tryCatch(rvest::html_table(stat_table, fill = TRUE), error = function(e) NULL)
  if (is.null(parsed) || nrow(parsed) == 0) {
    return(list(status = "empty_stats", detail = "Stats table is empty", df = NULL, links = character(0)))
  }

  links <- rvest::html_elements(stat_table, "#stat_grid a") |>
    rvest::html_attr("href")
  links <- links[!is.na(links) & nzchar(links)]

  list(status = "success", detail = NULL, df = parsed, links = links)
}

ncaa_normalize_rows <- function(df, team_info, year, type) {
  clean_names <- names(df)
  clean_names <- gsub("[^A-Za-z0-9_]+", "_", clean_names)
  clean_names <- gsub("^_+|_+$", "", clean_names)
  clean_names <- tolower(clean_names)
  names(df) <- clean_names

  df$year <- as.integer(year)
  df$stat_type <- as.character(type)
  df$team_id <- as.integer(team_info$team_id[[1]])
  df$team_name <- as.character(team_info$team_name[[1]])
  df
}
