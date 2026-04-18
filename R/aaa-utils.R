`%||%` <- function(x, y) if (is.null(x)) y else x

.safe_numeric <- function(x) {
  out <- suppressWarnings(as.numeric(as.character(x)))
  out[is.na(out)] <- 0
  out
}

.to_ip_float <- function(ip) {
  ip_chr <- trimws(as.character(ip))
  out <- rep(NA_real_, length(ip_chr))
  for (idx in seq_along(ip_chr)) {
    value <- ip_chr[[idx]]
    if (is.na(value) || value == "") next
    parts <- strsplit(value, "\\.", fixed = FALSE)[[1]]
    whole <- suppressWarnings(as.numeric(parts[[1]]))
    frac <- if (length(parts) > 1) parts[[2]] else "0"
    frac_digits <- suppressWarnings(as.numeric(frac))
    if (!is.finite(whole)) next
    if (!is.finite(frac_digits)) frac_digits <- 0
    thirds <- dplyr::case_when(
      frac_digits == 0 ~ 0,
      frac_digits == 1 ~ 1 / 3,
      frac_digits == 2 ~ 2 / 3,
      TRUE ~ frac_digits / 10
    )
    out[[idx]] <- whole + thirds
  }
  out
}
