test_that("file checksum helper returns sha256 and byte length", {
  chk <- getFromNamespace(".file_checksum_entry", "ncaaStatsSync")
  tmp <- tempfile(fileext = ".txt")
  writeLines("hello ncaa", tmp)
  on.exit(unlink(tmp), add = TRUE)
  ent <- chk(tmp)
  expect_type(ent$sha256, "character")
  expect_match(ent$sha256, "^[a-f0-9]{64}$")
  expect_equal(ent$bytes, as.integer(file.info(tmp)$size))
})

test_that("file checksum helper returns NULL for missing path", {
  chk <- getFromNamespace(".file_checksum_entry", "ncaaStatsSync")
  expect_null(chk(tempfile()))
})
