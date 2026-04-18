#' Team-level stat engine: aggregate player rows into team totals + qualified slices.
#'
#' Mirrors Pitch Tracker semantics: full-roster sums plus optional qualified
#' pitching (minimum IP) and qualified batting (minimum PA).

.add_team_context <- function(df, type = c("pitching", "batting")) {
  type <- match.arg(type)
  if (is.null(df) || nrow(df) == 0) return(df)
  if (type == "pitching") {
    higher_better <- c("k_pct", "k_minus_bb_pct")
    lower_better <- c("era", "whip", "bb_pct")
  } else {
    higher_better <- c("avg", "obp", "slg", "ops", "bb_pct")
    lower_better <- c("k_pct")
  }
  metrics <- unique(c(higher_better, lower_better))
  for (m in metrics) {
    df <- .apply_conference_baseline(df, m, "conference")
  }
  for (m in higher_better) {
    df <- .apply_percentiles(df, m, TRUE, NULL, "overall")
    df <- .apply_percentiles(df, m, TRUE, "conference", "conference")
  }
  for (m in lower_better) {
    df <- .apply_percentiles(df, m, FALSE, NULL, "overall")
    df <- .apply_percentiles(df, m, FALSE, "conference", "conference")
  }
  df
}

ncaa_aggregate_team_pitching <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    return(tibble::tibble())
  }

  df |>
    dplyr::group_by(.data$team_id, .data$team_name, .data$conference, .data$conference_id, .data$division, .data$year) |>
    dplyr::summarise(
      roster_pitchers = dplyr::n(),
      app = sum(.data$app, na.rm = TRUE),
      gs = sum(.data$gs, na.rm = TRUE),
      ip_float = sum(.data$ip_float, na.rm = TRUE),
      w = sum(.data$w, na.rm = TRUE),
      l = sum(.data$l, na.rm = TRUE),
      sv = sum(.data$sv, na.rm = TRUE),
      bf = sum(.data$bf, na.rm = TRUE),
      er = sum(.data$er, na.rm = TRUE),
      h = sum(.data$h, na.rm = TRUE),
      bb = sum(.data$bb, na.rm = TRUE),
      so = sum(.data$so, na.rm = TRUE),
      hb = sum(.data$hb, na.rm = TRUE),
      hr_a = sum(.data$hr_a, na.rm = TRUE),
      war = sum(.data$war %||% 0, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      era = dplyr::if_else(.data$ip_float > 0, 9 * .data$er / .data$ip_float, NA_real_),
      whip = dplyr::if_else(.data$ip_float > 0, (.data$h + .data$bb) / .data$ip_float, NA_real_),
      k_pct = dplyr::if_else(.data$bf > 0, (.data$so / .data$bf) * 100, NA_real_),
      bb_pct = dplyr::if_else(.data$bf > 0, (.data$bb / .data$bf) * 100, NA_real_),
      k_minus_bb_pct = .data$k_pct - .data$bb_pct
    ) |>
    dplyr::arrange(.data$team_name) |>
    .add_team_context("pitching")
}

ncaa_aggregate_qualified_team_pitching <- function(df, min_ip = 5) {
  if (is.null(df) || nrow(df) == 0) {
    return(tibble::tibble())
  }
  min_ip_threshold <- min_ip
  q <- df |> dplyr::filter(.data$ip_float >= min_ip_threshold)
  if (nrow(q) == 0) {
    return(tibble::tibble())
  }

  q |>
    dplyr::group_by(.data$team_id, .data$team_name, .data$conference, .data$conference_id, .data$division, .data$year) |>
    dplyr::summarise(
      qualified_pitchers = dplyr::n(),
      ip_float = sum(.data$ip_float, na.rm = TRUE),
      h = sum(.data$h, na.rm = TRUE),
      er = sum(.data$er, na.rm = TRUE),
      bb = sum(.data$bb, na.rm = TRUE),
      so = sum(.data$so, na.rm = TRUE),
      bf = sum(.data$bf, na.rm = TRUE),
      war = sum(.data$war %||% 0, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(min_ip = min_ip_threshold) |>
    dplyr::relocate(.data$min_ip, .after = .data$qualified_pitchers) |>
    dplyr::mutate(
      era = dplyr::if_else(.data$ip_float > 0, 9 * .data$er / .data$ip_float, NA_real_),
      whip = dplyr::if_else(.data$ip_float > 0, (.data$h + .data$bb) / .data$ip_float, NA_real_),
      k_pct = dplyr::if_else(.data$bf > 0, (.data$so / .data$bf) * 100, NA_real_),
      bb_pct = dplyr::if_else(.data$bf > 0, (.data$bb / .data$bf) * 100, NA_real_),
      k_minus_bb_pct = .data$k_pct - .data$bb_pct
    ) |>
    dplyr::arrange(.data$team_name) |>
    .add_team_context("pitching")
}

ncaa_aggregate_team_batting <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    return(tibble::tibble())
  }

  df |>
    dplyr::group_by(.data$team_id, .data$team_name, .data$conference, .data$conference_id, .data$division, .data$year) |>
    dplyr::summarise(
      roster_hitters = dplyr::n(),
      gp = sum(.data$gp, na.rm = TRUE),
      ab = sum(.data$ab, na.rm = TRUE),
      h = sum(.data$h, na.rm = TRUE),
      doubles = sum(.data$doubles, na.rm = TRUE),
      triples = sum(.data$triples, na.rm = TRUE),
      tb = sum(.data$tb, na.rm = TRUE),
      hr = sum(.data$hr, na.rm = TRUE),
      rbi = sum(.data$rbi, na.rm = TRUE),
      bb = sum(.data$bb, na.rm = TRUE),
      hbp = sum(.data$hbp, na.rm = TRUE),
      sf = sum(.data$sf, na.rm = TRUE),
      sh = sum(.data$sh, na.rm = TRUE),
      so = sum(.data$so, na.rm = TRUE),
      sb = sum(.data$sb, na.rm = TRUE),
      cs = sum(.data$cs, na.rm = TRUE),
      r = sum(.data$r, na.rm = TRUE),
      war = sum(.data$war %||% 0, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      pa = .data$ab + .data$bb + .data$hbp + .data$sf + .data$sh,
      avg = dplyr::if_else(.data$ab > 0, .data$h / .data$ab, NA_real_),
      obp = dplyr::if_else(
        (.data$ab + .data$bb + .data$hbp + .data$sf) > 0,
        (.data$h + .data$bb + .data$hbp) / (.data$ab + .data$bb + .data$hbp + .data$sf),
        NA_real_
      ),
      slg = dplyr::if_else(.data$ab > 0, .data$tb / .data$ab, NA_real_),
      ops = .data$obp + .data$slg,
      k_pct = dplyr::if_else(.data$pa > 0, (.data$so / .data$pa) * 100, NA_real_),
      bb_pct = dplyr::if_else(.data$pa > 0, (.data$bb / .data$pa) * 100, NA_real_)
    ) |>
    dplyr::arrange(.data$team_name) |>
    .add_team_context("batting")
}

ncaa_aggregate_qualified_team_batting <- function(df, min_pa = 15) {
  if (is.null(df) || nrow(df) == 0) {
    return(tibble::tibble())
  }
  min_pa_threshold <- min_pa
  df2 <- df |>
    dplyr::mutate(
      pa = .data$ab + .data$bb + .data$hbp + .data$sf + .data$sh
    )
  q <- df2 |> dplyr::filter(.data$pa >= min_pa_threshold)
  if (nrow(q) == 0) {
    return(tibble::tibble())
  }

  ncaa_aggregate_team_batting(q) |>
    dplyr::rename(qualified_hitters = .data$roster_hitters) |>
    dplyr::mutate(min_pa = min_pa_threshold) |>
    .add_team_context("batting")
}

#' Build full team stat bundle for one season from player-level frames.
ncaa_build_team_stat_engine <- function(pitching_players, batting_players, min_ip = 5, min_pa = 15) {
  list(
    schema_version = "1.0",
    pitching_teams = ncaa_aggregate_team_pitching(pitching_players),
    pitching_teams_qualified = ncaa_aggregate_qualified_team_pitching(pitching_players, min_ip),
    batting_teams = ncaa_aggregate_team_batting(batting_players),
    batting_teams_qualified = ncaa_aggregate_qualified_team_batting(batting_players, min_pa),
    qualification = list(min_ip = min_ip, min_pa = min_pa)
  )
}
