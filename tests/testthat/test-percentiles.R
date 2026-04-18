test_that("player contextual benchmarks are added for pitching", {
  x <- tibble::tibble(
    conference = c("A", "A", "B"),
    era = c(2, 4, 3),
    whip = c(1.1, 1.4, 1.2),
    bb_pct = c(5, 8, 6),
    k_pct = c(30, 20, 25),
    k_minus_bb_pct = c(25, 12, 19),
    era_plus = c(150, 90, 110),
    war = c(1.2, 0.3, 0.8),
    so_bb = c(5, 2.5, 3.5),
    k9 = c(11, 8, 9),
    gb_pct = c(48, 42, 45),
    lob_pct = c(78, 70, 74),
    fip = c(2.8, 4.2, 3.5),
    xfip = c(3.0, 4.0, 3.4),
    h9 = c(6.9, 9.4, 8.1),
    bb9 = c(2.1, 3.5, 2.8),
    hr9 = c(0.7, 1.4, 1.1),
    babip = c(0.25, 0.33, 0.29)
  )

  out <- add_contextual_benchmarks(x, "pitching")
  expect_true("conference_mean_era" %in% names(out))
  expect_true("overall_percentile_k_pct" %in% names(out))
  expect_true("conference_percentile_era" %in% names(out))
})

test_that("team engine includes conference percentile columns", {
  bat <- tibble::tibble(
    team_id = c(1L, 1L, 2L, 2L),
    team_name = c("A", "A", "B", "B"),
    conference = c("C1", "C1", "C2", "C2"),
    conference_id = c(1L, 1L, 2L, 2L),
    division = c(3L, 3L, 3L, 3L),
    year = c(2026L, 2026L, 2026L, 2026L),
    gp = c(10, 10, 10, 10),
    ab = c(30, 40, 35, 45),
    h = c(10, 15, 9, 16),
    doubles = c(2, 3, 1, 3),
    triples = c(0, 1, 0, 1),
    tb = c(16, 24, 13, 25),
    hr = c(1, 2, 1, 2),
    rbi = c(8, 12, 7, 11),
    bb = c(5, 7, 4, 8),
    hbp = c(1, 1, 1, 1),
    sf = c(1, 1, 1, 1),
    sh = c(0, 0, 0, 0),
    so = c(6, 9, 8, 10),
    sb = c(2, 3, 2, 3),
    cs = c(1, 1, 1, 1),
    r = c(7, 10, 6, 11),
    war = c(0.2, 0.3, 0.15, 0.35)
  )
  out <- ncaa_aggregate_team_batting(bat)
  expect_true("conference_mean_ops" %in% names(out))
  expect_true("overall_percentile_ops" %in% names(out))
})
