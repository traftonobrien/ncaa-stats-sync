test_that("team pitching aggregates sum counting stats and rate stats", {
  pitch <- tibble::tibble(
    team_id = c(1L, 1L),
    team_name = c("A", "A"),
    conference = c("East", "East"),
    conference_id = c(1L, 1L),
    division = c(3L, 3L),
    year = c(2026L, 2026L),
    app = c(1L, 1L),
    gs = c(0L, 0L),
    w = c(0L, 0L),
    l = c(0L, 0L),
    sv = c(0L, 0L),
    ip_float = c(3, 3),
    er = c(1, 1),
    h = c(2, 2),
    bb = c(1, 1),
    so = c(3, 3),
    bf = c(10, 10),
    hr_a = c(0, 0),
    hb = c(0, 0),
    war = c(0.1, 0.2)
  )
  out <- ncaa_aggregate_team_pitching(pitch)
  expect_equal(nrow(out), 1L)
  expect_equal(out$ip_float[[1]], 6)
  expect_equal(out$er[[1]], 2)
  expect_equal(out$era[[1]], (2 * 9) / 6)
})

test_that("qualified pitching respects minimum IP threshold", {
  pitch <- tibble::tibble(
    team_id = c(1L, 1L, 1L),
    team_name = c("A", "A", "A"),
    conference = c("E", "E", "E"),
    conference_id = c(1L, 1L, 1L),
    division = c(3L, 3L, 3L),
    year = c(2026L, 2026L, 2026L),
    app = c(1L, 1L, 1L),
    gs = c(0L, 1L, 1L),
    w = c(0L, 1L, 0L),
    l = c(0L, 0L, 1L),
    sv = c(0L, 0L, 0L),
    ip_float = c(1, 6, 6),
    er = c(0, 2, 1),
    h = c(1, 3, 3),
    bb = c(0, 1, 1),
    so = c(1, 4, 4),
    bf = c(5, 20, 20),
    hr_a = c(0L, 0L, 0L),
    hb = c(0L, 0L, 0L),
    war = c(0, 0.2, 0.1)
  )
  q <- ncaa_aggregate_qualified_team_pitching(pitch, min_ip = 5)
  expect_equal(nrow(q), 1L)
  expect_equal(q$qualified_pitchers[[1]], 2L)
  expect_equal(q$ip_float[[1]], 12)
})
