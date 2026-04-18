#!/usr/bin/env Rscript

suppressWarnings(suppressMessages({
  library(ncaaStatsSync)
}))

res <- ncaa_stats_doctor()
if (!isTRUE(res$healthy)) quit(status = 1)
