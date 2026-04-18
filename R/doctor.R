#' Environment and dependency checks before running a sync.
#'
#' Prints OK/FAIL lines and invisibly returns a list of results. Intended for
#' onboarding, CI images, and support debugging.
#'
#' @export
ncaa_stats_doctor <- function() {
  ok <- TRUE
  results <- list()

  rv <- getRversion()
  results$r_version <- as.character(rv)
  if (rv < "4.1") {
    message("FAIL: R >= 4.1 required")
    ok <- FALSE
  } else {
    message(sprintf("OK: R %s", results$r_version))
  }

  pkgs <- c(
    "chromote", "collegebaseball", "dplyr", "jsonlite", "yaml",
    "digest", "tibble", "rvest", "stringr", "xml2", "baseballr", "rlang"
  )
  for (p in pkgs) {
    if (requireNamespace(p, quietly = TRUE)) {
      message(sprintf("OK: package %s", p))
      results[[paste0("pkg_", p)]] <- TRUE
    } else {
      message(sprintf("FAIL: missing package %s", p))
      results[[paste0("pkg_", p)]] <- FALSE
      ok <- FALSE
    }
  }

  chrome <- Sys.getenv("CHROMOTE_CHROME", unset = "")
  if (nzchar(chrome) && file.exists(chrome)) {
    message(sprintf("OK: CHROMOTE_CHROME=%s", chrome))
    results$chrome <- chrome
  } else {
    cand <- c(
      "/usr/bin/google-chrome-stable",
      "/usr/bin/google-chrome",
      "/usr/bin/chromium-browser",
      "/usr/bin/chromium",
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    )
    hit <- cand[file.exists(cand)][1]
    if (!is.na(hit)) {
      message(sprintf("OK: found browser at %s (set CHROMOTE_CHROME to pin)", hit))
      results$chrome <- hit
    } else {
      message("WARN: no CHROMOTE_CHROME and no common Chrome/Chromium path found")
      results$chrome <- NA_character_
    }
  }

  results$healthy <- ok
  if (!ok) {
    message("\nDoctor finished with failures - fix items above before syncing.")
  } else {
    message("\nDoctor finished: ready to run a sync (network + NCAA availability not tested).")
  }
  invisible(results)
}
