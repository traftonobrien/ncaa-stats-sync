.NCAA_UA <- paste(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
  "AppleWebKit/537.36 (KHTML, like Gecko)",
  "Chrome/124.0.0.0 Safari/537.36"
)

.NCAA_BASE_URL <- "https://stats.ncaa.org"

.ncaa_state <- new.env(parent = emptyenv())
.ncaa_state$session <- NULL

ncaa_stats_url <- function(team_id, year_stat_category_id) {
  sprintf(
    "%s/teams/%s/season_to_date_stats?year_stat_category_id=%s",
    .NCAA_BASE_URL,
    as.integer(team_id),
    as.integer(year_stat_category_id)
  )
}

.ncaa_get_session <- function() {
  if (is.null(.ncaa_state$session)) {
    ses <- chromote::ChromoteSession$new()
    ses$Network$enable()
    ses$Network$setUserAgentOverride(userAgent = .NCAA_UA)
    .ncaa_state$session <- ses
  }
  .ncaa_state$session
}

.ncaa_close_session <- function() {
  if (!is.null(.ncaa_state$session)) {
    try(.ncaa_state$session$close(), silent = TRUE)
    .ncaa_state$session <- NULL
  }
}

ncaa_fetch_page <- function(url, max_wait_seconds = 8L, max_retries = 4L) {
  last_result <- NULL

  for (attempt in seq_len(max_retries)) {
    result <- tryCatch({
      ses <- .ncaa_get_session()
      ses$Page$navigate(url = url)

      started <- Sys.time()
      html <- NULL

      while (as.numeric(difftime(Sys.time(), started, units = "secs")) < max_wait_seconds) {
        state <- ses$Runtime$evaluate("
          (() => {
            const body = document.body ? document.body.innerText : '';
            return {
              title: document.title || '',
              ready: document.readyState || '',
              accessDenied: /access denied/i.test(body) || /access denied/i.test(document.title || ''),
              tableCount: document.querySelectorAll('table').length,
              statGridLinks: document.querySelectorAll('#stat_grid a').length
            };
          })()
        ")$result$value

        if (isTRUE(state$accessDenied)) {
          return(list(status = "access_denied", html = NULL, attempts = attempt, error = "Access denied"))
        }

        if ((state$tableCount %||% 0L) >= 2L && (state$statGridLinks %||% 0L) > 0L) {
          doc <- ses$DOM$getDocument()
          html <- ses$DOM$getOuterHTML(nodeId = doc$root$nodeId)[["outerHTML"]]
          break
        }

        if (isTRUE(state$ready == "complete") && (state$tableCount %||% 0L) < 2L) {
          doc <- ses$DOM$getDocument()
          html <- ses$DOM$getOuterHTML(nodeId = doc$root$nodeId)[["outerHTML"]]
          break
        }

        Sys.sleep(0.2)
      }

      if (is.null(html)) {
        doc <- ses$DOM$getDocument()
        html <- ses$DOM$getOuterHTML(nodeId = doc$root$nodeId)[["outerHTML"]]
      }

      try(ses$Page$navigate(url = "about:blank"), silent = TRUE)
      list(status = "success", html = html, attempts = attempt, error = NULL)
    }, error = function(e) {
      .ncaa_state$session <- NULL
      list(status = "parse_failed", html = NULL, attempts = attempt, error = conditionMessage(e))
    })

    last_result <- result
    if (identical(result$status, "success")) break
    if (attempt < max_retries) {
      try(.ncaa_close_session(), silent = TRUE)
      Sys.sleep(2 + (attempt * 2))
    }
  }

  last_result
}
