test_that("ncaa_stats_doctor returns a structured result", {
  res <- suppressMessages(ncaa_stats_doctor())
  expect_true(is.list(res))
  expect_true("healthy" %in% names(res))
})
