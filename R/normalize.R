#' Extract pitching player rows from raw NCAA table + player links.
extract_pitching_rows <- function(raw_df, links, team_info) {
  yr <- if ("year" %in% names(team_info)) as.integer(team_info$year[[1]]) else NA_integer_
  raw_df |>
    dplyr::mutate(`#` = suppressWarnings(as.numeric(`#`))) |>
    dplyr::filter(!is.na(`#`)) |>
    dplyr::mutate(
      App = .safe_numeric(.data$App),
      GS = .safe_numeric(.data$GS),
      ERA = .safe_numeric(.data$ERA),
      H = .safe_numeric(.data$H),
      R = .safe_numeric(.data$R),
      ER = .safe_numeric(.data$ER),
      BB = .safe_numeric(.data$BB),
      SO = .safe_numeric(.data$SO),
      BF = .safe_numeric(.data$BF),
      `HR-A` = .safe_numeric(.data$`HR-A`),
      HB = .safe_numeric(.data$HB),
      Pitches = .safe_numeric(.data$Pitches),
      GO = .safe_numeric(.data$GO),
      FO = .safe_numeric(.data$FO),
      W = .safe_numeric(.data$W),
      L = .safe_numeric(.data$L),
      SV = .safe_numeric(.data$SV),
      IBB = .safe_numeric(.data$IBB),
      ip_text = as.character(.data$IP),
      ip_float = .to_ip_float(.data$IP)
    ) |>
    dplyr::rename(
      player_name = "Player",
      jersey = "#",
      hr_a = "HR-A",
      hb = "HB",
      bb = "BB",
      so = "SO",
      bf = "BF",
      h = "H",
      r = "R",
      er = "ER",
      app = "App",
      gs = "GS",
      era = "ERA",
      pitches = "Pitches",
      go = "GO",
      fo = "FO",
      w = "W",
      l = "L",
      sv = "SV",
      ibb = "IBB"
    ) |>
    dplyr::left_join(links, by = "player_name") |>
    dplyr::transmute(
      player_id = as.character(.data$player_id),
      player_url = as.character(.data$player_url),
      player_name = .data$player_name,
      team_id = as.integer(team_info$team_id[[1]]),
      team_name = as.character(team_info$team_name[[1]]),
      conference = as.character(team_info$conference[[1]] %||% NA_character_),
      conference_id = as.integer(team_info$conference_id[[1]] %||% NA_integer_),
      division = as.integer(team_info$division[[1]] %||% NA_integer_),
      year = yr,
      jersey = as.integer(.data$jersey),
      yr = as.character(.data$Yr),
      pos = as.character(.data$Pos),
      ht = as.character(.data$Ht),
      bats = stringr::str_sub(as.character(.data$`B/T`), 1, 1),
      throws = stringr::str_sub(as.character(.data$`B/T`), -1, -1),
      app = .data$app,
      gs = .data$gs,
      era = .data$era,
      ip = .data$ip_text,
      ip_float = .data$ip_float,
      h = .data$h,
      r = .data$r,
      er = .data$er,
      bb = .data$bb,
      so = .data$so,
      bf = .data$bf,
      hr_a = .data$hr_a,
      hb = .data$hb,
      pitches = .data$pitches,
      go = .data$go,
      fo = .data$fo,
      w = .data$w,
      l = .data$l,
      sv = .data$sv,
      ibb = .data$ibb
    )
}

#' Extract batting player rows.
extract_batting_rows <- function(raw_df, links, team_info) {
  yr <- if ("year" %in% names(team_info)) as.integer(team_info$year[[1]]) else NA_integer_
  raw_df |>
    dplyr::mutate(`#` = suppressWarnings(as.numeric(`#`))) |>
    dplyr::filter(!is.na(`#`)) |>
    dplyr::mutate(
      AB = .safe_numeric(.data$AB),
      H = .safe_numeric(.data$H),
      `2B` = .safe_numeric(.data$`2B`),
      `3B` = .safe_numeric(.data$`3B`),
      TB = .safe_numeric(.data$TB),
      HR = .safe_numeric(.data$HR),
      RBI = .safe_numeric(.data$RBI),
      BB = .safe_numeric(.data$BB),
      HBP = .safe_numeric(.data$HBP),
      SF = .safe_numeric(.data$SF),
      SH = .safe_numeric(.data$SH),
      K = .safe_numeric(.data$K),
      SB = .safe_numeric(.data$SB),
      CS = .safe_numeric(.data$CS),
      R = .safe_numeric(.data$R),
      GP = .safe_numeric(.data$GP),
      GS = .safe_numeric(.data$GS)
    ) |>
    dplyr::rename(
      player_name = "Player",
      jersey = "#",
      ab = "AB",
      h = "H",
      doubles = "2B",
      triples = "3B",
      tb = "TB",
      hr = "HR",
      rbi = "RBI",
      bb = "BB",
      hbp = "HBP",
      sf = "SF",
      sh = "SH",
      so = "K",
      sb = "SB",
      cs = "CS",
      r = "R",
      gp = "GP",
      gs = "GS"
    ) |>
    dplyr::left_join(links, by = "player_name") |>
    dplyr::transmute(
      player_id = as.character(.data$player_id),
      player_url = as.character(.data$player_url),
      player_name = .data$player_name,
      team_id = as.integer(team_info$team_id[[1]]),
      team_name = as.character(team_info$team_name[[1]]),
      conference = as.character(team_info$conference[[1]] %||% NA_character_),
      conference_id = as.integer(team_info$conference_id[[1]] %||% NA_integer_),
      division = as.integer(team_info$division[[1]] %||% NA_integer_),
      year = yr,
      jersey = as.integer(.data$jersey),
      yr = as.character(.data$Yr),
      pos = as.character(.data$Pos),
      ht = as.character(.data$Ht),
      bats = stringr::str_sub(as.character(.data$`B/T`), 1, 1),
      throws = stringr::str_sub(as.character(.data$`B/T`), -1, -1),
      gp = .data$gp,
      gs = .data$gs,
      ab = .data$ab,
      h = .data$h,
      doubles = .data$doubles,
      triples = .data$triples,
      tb = .data$tb,
      hr = .data$hr,
      rbi = .data$rbi,
      bb = .data$bb,
      hbp = .data$hbp,
      sf = .data$sf,
      sh = .data$sh,
      so = .data$so,
      sb = .data$sb,
      cs = .data$cs,
      r = .data$r
    )
}

add_pitching_derived_metrics <- function(df) {
  if (nrow(df) == 0) return(df)

  total_ip <- sum(df$ip_float, na.rm = TRUE)
  total_er <- sum(df$er, na.rm = TRUE)
  total_hr <- sum(df$hr_a, na.rm = TRUE)
  total_bb_hb <- sum(df$bb + df$hb, na.rm = TRUE)
  total_so <- sum(df$so, na.rm = TRUE)
  total_fb <- sum(df$fo + df$hr_a, na.rm = TRUE)
  lg_era <- if (total_ip > 0) (total_er * 9) / total_ip else 0
  fip_constant <- if (total_ip > 0) {
    lg_era - ((13 * total_hr + 3 * total_bb_hb - 2 * total_so) / total_ip)
  } else {
    0
  }
  lg_hr_fb <- if (total_fb > 0) total_hr / total_fb else 0.1

  df <- df |>
    dplyr::mutate(
      whip = dplyr::if_else(.data$ip_float > 0, (.data$h + .data$bb) / .data$ip_float, NA_real_),
      k_pct = dplyr::if_else(.data$bf > 0, (.data$so / .data$bf) * 100, NA_real_),
      bb_pct = dplyr::if_else(.data$bf > 0, (.data$bb / .data$bf) * 100, NA_real_),
      k_minus_bb_pct = .data$k_pct - .data$bb_pct,
      k9 = dplyr::if_else(.data$ip_float > 0, (9 * .data$so) / .data$ip_float, NA_real_),
      bb9 = dplyr::if_else(.data$ip_float > 0, (9 * .data$bb) / .data$ip_float, NA_real_),
      h9 = dplyr::if_else(.data$ip_float > 0, (9 * .data$h) / .data$ip_float, NA_real_),
      hr9 = dplyr::if_else(.data$ip_float > 0, (9 * .data$hr_a) / .data$ip_float, NA_real_),
      go_fo_ratio = dplyr::if_else(.data$fo > 0, .data$go / .data$fo, NA_real_),
      gb_pct = dplyr::if_else((.data$go + .data$fo) > 0, 100 * .data$go / (.data$go + .data$fo), NA_real_),
      fb_pct = dplyr::if_else((.data$go + .data$fo) > 0, 100 * .data$fo / (.data$go + .data$fo), NA_real_),
      hr_fb_pct = dplyr::if_else(.data$fo > 0, 100 * .data$hr_a / .data$fo, NA_real_),
      so_bb = dplyr::if_else(.data$bb > 0, .data$so / .data$bb, NA_real_),
      babip = dplyr::if_else((.data$bf - .data$bb - .data$so - .data$hr_a - .data$hb) > 0,
        (.data$h - .data$hr_a) / (.data$bf - .data$bb - .data$so - .data$hr_a - .data$hb), NA_real_),
      lob_pct = dplyr::if_else((.data$h + .data$bb + .data$hb - 1.4 * .data$hr_a) > 0,
        100 * (.data$h + .data$bb + .data$hb - .data$r) / (.data$h + .data$bb + .data$hb - 1.4 * .data$hr_a), NA_real_),
      fip = dplyr::if_else(
        .data$ip_float > 0,
        ((13 * .data$hr_a + 3 * (.data$bb + .data$hb) - 2 * .data$so) / .data$ip_float) + fip_constant,
        NA_real_
      ),
      expected_hr = (.data$fo + .data$hr_a) * lg_hr_fb,
      xfip = dplyr::if_else(
        .data$ip_float > 0,
        ((13 * .data$expected_hr + 3 * (.data$bb + .data$hb) - 2 * .data$so) / .data$ip_float) + fip_constant,
        NA_real_
      )
    )

  lg_fip <- stats::weighted.mean(df$fip, w = pmax(df$ip_float, 0), na.rm = TRUE)
  replacement_fip <- lg_fip + 1
  runs_per_win <- 10

  df |>
    dplyr::mutate(
      era_plus = dplyr::if_else(
        .data$era > 0,
        100 * (lg_era / .data$era),
        dplyr::if_else(.data$ip_float > 0 & .data$er == 0, 999, NA_real_)
      ),
      war = dplyr::if_else(
        .data$ip_float > 0,
        ((replacement_fip - .data$fip) * .data$ip_float / 9) / runs_per_win,
        NA_real_
      )
    ) |>
    dplyr::select(-"expected_hr")
}

add_batting_derived_metrics <- function(df) {
  if (nrow(df) == 0) return(df)

  df <- df |>
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
      bb_pct = dplyr::if_else(.data$pa > 0, (.data$bb / .data$pa) * 100, NA_real_),
      singles = pmax(0, .data$h - .data$doubles - .data$triples - .data$hr),
      xbh = .data$doubles + .data$triples + .data$hr,
      iso = .data$slg - .data$avg,
      babip = dplyr::if_else((.data$ab - .data$so - .data$hr + .data$sf) > 0,
        (.data$h - .data$hr) / (.data$ab - .data$so - .data$hr + .data$sf), NA_real_),
      bb_k_ratio = dplyr::if_else(.data$so > 0, .data$bb / .data$so, NA_real_),
      sb_pct = dplyr::if_else((.data$sb + .data$cs) > 0, 100 * .data$sb / (.data$sb + .data$cs), NA_real_),
      rc = ((.data$h + .data$bb + .data$hbp) * .data$tb) /
        pmax(1, (.data$ab + .data$bb + .data$hbp + .data$sf + .data$sh))
    )

  lg_rc_pa <- sum(df$rc, na.rm = TRUE) / max(1, sum(df$pa, na.rm = TRUE))

  df |>
    dplyr::mutate(
      wrc_plus = dplyr::if_else(
        .data$pa > 0 & lg_rc_pa > 0,
        ((.data$rc / .data$pa) / lg_rc_pa) * 100,
        NA_real_
      ),
      war = dplyr::if_else(
        .data$pa > 0,
        (((.data$rc / pmax(.data$pa, 1)) - lg_rc_pa) * .data$pa) / 10,
        NA_real_
      )
    ) |>
    dplyr::select(-"rc")
}

.apply_percentiles <- function(df, metric, larger_is_better = TRUE, group_col = NULL, prefix = "overall") {
  if (!metric %in% names(df)) return(df)
  new_col <- sprintf("%s_percentile_%s", prefix, metric)
  metric_sym <- rlang::sym(metric)
  new_sym <- rlang::sym(new_col)
  if (is.null(group_col)) {
    out <- if (larger_is_better) dplyr::percent_rank(df[[metric]]) else dplyr::percent_rank(-df[[metric]])
    df[[new_col]] <- 100 * out
    return(df)
  }
  group_sym <- rlang::sym(group_col)
  df |>
    dplyr::group_by(!!group_sym) |>
    dplyr::mutate(!!new_sym := 100 * if (larger_is_better) dplyr::percent_rank(!!metric_sym) else dplyr::percent_rank(-(!!metric_sym))) |>
    dplyr::ungroup()
}

.apply_conference_baseline <- function(df, metric, group_col = "conference") {
  if (!metric %in% names(df)) return(df)
  metric_sym <- rlang::sym(metric)
  mean_col <- rlang::sym(sprintf("conference_mean_%s", metric))
  sd_col <- rlang::sym(sprintf("conference_sd_%s", metric))
  delta_col <- rlang::sym(sprintf("conference_delta_%s", metric))
  group_sym <- rlang::sym(group_col)
  df |>
    dplyr::group_by(!!group_sym) |>
    dplyr::mutate(
      !!mean_col := mean(!!metric_sym, na.rm = TRUE),
      !!sd_col := stats::sd(!!metric_sym, na.rm = TRUE),
      !!delta_col := !!metric_sym - !!mean_col
    ) |>
    dplyr::ungroup()
}

add_contextual_benchmarks <- function(df, type = c("pitching", "batting")) {
  type <- match.arg(type)
  if (nrow(df) == 0) return(df)

  if (type == "pitching") {
    higher_better <- c("k_pct", "k_minus_bb_pct", "era_plus", "war", "so_bb", "k9", "gb_pct", "lob_pct")
    lower_better <- c("era", "whip", "bb_pct", "fip", "xfip", "h9", "bb9", "hr9", "babip")
  } else {
    higher_better <- c("avg", "obp", "slg", "ops", "wrc_plus", "war", "bb_pct", "iso", "sb_pct", "bb_k_ratio")
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
