#' Default sync configuration.
#'
#' @returns Named list used by `ncaa_sync_daily()`.
#' @export
ncaa_default_config <- function() {
  list(
    years = c(2026L),
    division = 3L,
    types = c("pitching", "batting"),
    output_dir = "output/college-stats",
    mode = "incremental",
    watch_list = character(0),
    max_wait_seconds = 8L,
    max_retries = 4L,
    access_denied_team_retries = 3L,
    access_denied_backoff_seconds = 12L,
    request_interval_seconds = 0.6,
    access_denied_team_cooldown_seconds = 3,
    write_team_stats = TRUE,
    min_ip_qualified = 5,
    min_pa_qualified = 15,
    schema_version = "1.0"
  )
}

#' Load YAML config and merge with defaults.
#'
#' @param config_path Optional path to a YAML config file.
#' @returns Named list configuration for sync functions.
#' @export
ncaa_load_config <- function(config_path = NULL) {
  cfg <- ncaa_default_config()
  if (is.null(config_path)) return(cfg)

  loaded <- yaml::read_yaml(config_path)
  if (is.null(loaded)) return(cfg)

  utils::modifyList(cfg, loaded)
}
