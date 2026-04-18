#' Parse NCAA stats HTML (deterministic classification).
#'
#' @returns List with `status`, `df`, `links`, `detail`.
ncaa_parse_stats_html <- function(html, type = c("pitching", "batting")) {
  type <- match.arg(type)

  if (is.null(html) || !nzchar(html)) {
    return(list(status = "parse_failed", df = NULL, links = NULL, detail = "Empty HTML"))
  }

  if (grepl("access denied", html, ignore.case = TRUE) ||
    grepl("<title>Access Denied", html, ignore.case = TRUE)) {
    return(list(
      status = "access_denied", df = NULL, links = NULL,
      detail = "Access denied marker found in response body"
    ))
  }

  doc <- tryCatch(xml2::read_html(html), error = function(e) NULL)
  if (is.null(doc)) {
    return(list(status = "parse_failed", df = NULL, links = NULL, detail = "Failed to parse HTML document"))
  }

  tables <- rvest::html_elements(doc, "table")
  if (length(tables) < 2) {
    return(list(
      status = "empty_stats", df = NULL, links = NULL,
      detail = sprintf("Only %d table(s) found; stats not yet available", length(tables))
    ))
  }

  stat_table <- tryCatch(
    rvest::html_table(tables[[2]], convert = FALSE),
    error = function(e) NULL
  )
  if (is.null(stat_table) || !is.data.frame(stat_table)) {
    return(list(status = "parse_failed", df = NULL, links = NULL, detail = "Failed to read stat table"))
  }

  required_col <- if (identical(type, "pitching")) "ERA" else "AB"
  if (!"#" %in% colnames(stat_table) || !required_col %in% colnames(stat_table)) {
    return(list(
      status = "parse_failed", df = NULL, links = NULL,
      detail = sprintf("Missing required column '#' or '%s'", required_col)
    ))
  }

  player_rows <- stat_table[suppressWarnings(!is.na(as.numeric(stat_table[["#"]]))), ]
  if (nrow(player_rows) == 0) {
    return(list(
      status = "empty_stats", df = NULL, links = NULL,
      detail = "Stat table present but contains no player rows (early season)"
    ))
  }

  link_nodes <- rvest::html_elements(doc, "#stat_grid a")
  links <- tibble::tibble(
    player_name = rvest::html_text(link_nodes, trim = TRUE),
    href = rvest::html_attr(link_nodes, "href")
  ) |>
    dplyr::mutate(
      player_id = stringr::str_extract(.data$href, "(?<=/players/)\\d+"),
      player_url = dplyr::if_else(
        is.na(.data$href), NA_character_,
        paste0("https://stats.ncaa.org", .data$href)
      )
    )

  list(
    status = "success",
    df = tibble::as_tibble(stat_table),
    links = links,
    detail = NULL
  )
}
