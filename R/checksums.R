#' Compute SHA-256 hex digest of a file (bytes on disk).
#'
#' @param path Absolute or relative file path.
#' @returns List with `sha256`, `bytes`, or NULL if missing.
#' @keywords internal
#' @noRd
.file_checksum_entry <- function(path) {
  if (!nzchar(path) || !file.exists(path)) {
    return(NULL)
  }
  bytes <- file.info(path, extra_cols = FALSE)$size[[1]]
  sha <- digest::digest(path, algo = "sha256", file = TRUE)
  list(sha256 = as.character(sha), bytes = as.integer(bytes))
}
