#' Load NCAA season id table (remote RDS with embedded fallback).
.ncaa_season_ids <- function() {
  u <- "https://raw.githubusercontent.com/robert-frey/college-baseball/main/ncaa_season_ids.rds"
  tryCatch(
    {
      con <- url(u, "rb")
      on.exit(close(con), add = TRUE)
      readRDS(con)
    },
    error = function(e) {
      if (!requireNamespace("baseballr", quietly = TRUE)) {
        stop("Need baseballr for season id fallback: install.packages('baseballr')")
      }
      baseballr::load_ncaa_baseball_season_ids()
    }
  )
}

#' Resolve NCAA category id for year/type.
#'
#' @param season_ids Data frame from `.ncaa_season_ids()`.
#' @param year Integer season year.
#' @param type One of `"pitching"` or `"batting"`.
#' @returns Scalar category id used in NCAA stats URLs.
#' @export
ncaa_get_category_id <- function(season_ids, year, type) {
  year_row <- season_ids[season_ids$season == year, ]
  if (nrow(year_row) == 0) stop(sprintf("No NCAA season ids found for year %s", year))
  if (identical(type, "pitching")) return(year_row$pitching_id[[1]])
  if (identical(type, "batting")) return(year_row$batting_id[[1]])
  stop(sprintf("Unknown type: %s", type))
}
