#!/usr/bin/env Rscript

suppressWarnings(suppressMessages({
  library(ncaaStatsSync)
}))

parse_args <- function(args) {
  out <- list(
    config = "config.yml",
    mode = NULL,
    team_name = NULL,
    limit = NULL,
    smoke = FALSE
  )

  i <- 1
  while (i <= length(args)) {
    arg <- args[[i]]
    if (arg == "--config")    { out$config <- args[[i + 1]]; i <- i + 2; next }
    if (arg == "--mode")      { out$mode <- args[[i + 1]]; i <- i + 2; next }
    if (arg == "--team-name") { out$team_name <- args[[i + 1]]; i <- i + 2; next }
    if (arg == "--limit")     { out$limit <- as.integer(args[[i + 1]]); i <- i + 2; next }
    if (arg == "--smoke")     { out$smoke <- TRUE; i <- i + 1; next }
    stop(sprintf("Unknown argument: %s", arg))
  }

  out
}

args <- parse_args(commandArgs(trailingOnly = TRUE))

meta <- tryCatch(
  ncaa_sync_daily(
    config_path = args$config,
    mode = args$mode,
    team_name = args$team_name,
    limit = args$limit,
    smoke = isTRUE(args$smoke)
  ),
  error = function(e) {
    message(conditionMessage(e))
    quit(status = 1L)
  }
)

if (isTRUE(args$smoke)) {
  ok <- TRUE
  for (y in meta$years) {
    key <- sprintf("%s-pitching", y)
    entry <- meta$results[[key]]
    if (is.null(entry)) {
      ok <- FALSE
      next
    }
    oc <- entry$outcome_counts
    parse_failed <- if (is.null(oc$parse_failed)) 0L else as.integer(oc$parse_failed)
    access_denied <- if (is.null(oc$access_denied)) 0L else as.integer(oc$access_denied)
    if ((parse_failed + access_denied) > 0L) ok <- FALSE
  }
  required_files <- vapply(
    meta$years,
    function(y) sprintf("pitching-%s.json", y),
    character(1)
  )
  has_pitching_checksum <- all(required_files %in% names(meta$file_checksums))
  if (!ok || !has_pitching_checksum || !"meta.json" %in% names(meta$file_checksums)) {
    message("Smoke check failed: parse/access issues or missing expected checksums.")
    quit(status = 1L)
  }
}

cat(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE), "\n")
