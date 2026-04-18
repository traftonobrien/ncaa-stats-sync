#!/usr/bin/env Rscript

suppressWarnings(suppressMessages({
  library(ncaaStatsSync)
}))

parse_args <- function(args) {
  out <- list(
    config = "config.yml",
    mode = NULL,
    team_name = NULL,
    limit = NULL
  )

  i <- 1
  while (i <= length(args)) {
    arg <- args[[i]]
    if (arg == "--config")    { out$config <- args[[i + 1]]; i <- i + 2; next }
    if (arg == "--mode")      { out$mode <- args[[i + 1]]; i <- i + 2; next }
    if (arg == "--team-name") { out$team_name <- args[[i + 1]]; i <- i + 2; next }
    if (arg == "--limit")     { out$limit <- as.integer(args[[i + 1]]); i <- i + 2; next }
    stop(sprintf("Unknown argument: %s", arg))
  }

  out
}

args <- parse_args(commandArgs(trailingOnly = TRUE))
meta <- ncaa_sync_daily(
  config_path = args$config,
  mode = args$mode,
  team_name = args$team_name,
  limit = args$limit
)

cat(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE), "\n")
