`%||%` <- function(x, y) if (is.null(x)) y else x

ncaa_default_config <- function() {
  list(
    years = c(2026L),
    division = 3L,
    types = c("pitching", "batting"),
    output_dir = "output/college-stats",
    mode = "incremental",
    watch_list = c("Babson"),
    max_wait_seconds = 8L,
    max_retries = 4L
  )
}

ncaa_load_config <- function(config_path = NULL) {
  cfg <- ncaa_default_config()
  if (is.null(config_path)) return(cfg)

  loaded <- yaml::read_yaml(config_path)
  if (is.null(loaded)) return(cfg)

  modifyList(cfg, loaded)
}
