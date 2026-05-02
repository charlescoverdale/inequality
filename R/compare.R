#' Compare inequality measures
#'
#' Computes all major inequality indices on the same data and returns a
#' summary table for easy comparison.
#'
#' When `ci = TRUE` the function runs a single bootstrap loop, recomputing
#' every measure on each resample. This is far cheaper than calling each
#' measure with its own `ci = TRUE` and produces a CI for every row of the
#' table.
#'
#' By default `iq_compare()` requires strictly positive values because the
#' Theil and Atkinson rows are mathematically undefined at zero or below.
#' Pass `negatives = "keep"` to permit zero or negative values: the
#' Theil and Atkinson rows are returned as `NA` in that case, while the
#' Gini, S-Gini, Kolm, Wolfson, Palma, Hoover and percentile-ratio rows
#' are computed using the formulas appropriate for that input.
#'
#' @param x Numeric vector of incomes (strictly positive by default; see
#'   `negatives`).
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap CIs for every measure in the
#'   table? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#' @param negatives Character. `"error"` (default) requires strictly
#'   positive `x`; `"keep"` permits zero or negative values, with `NA`
#'   returned for measures that are undefined on those values.
#'
#' @return An S3 object of class `"iq_comparison"` with elements:
#' \describe{
#'   \item{table}{data.frame with columns `measure`, `value`, and (when
#'     `ci = TRUE`) `ci_lower` and `ci_upper`.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{level}{Numeric or `NULL`. Confidence level.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_compare(d$income)
#'
#' # CIs for every measure in the table (one bootstrap loop, all rows)
#' iq_compare(d$income, ci = TRUE, R = 200)
#'
#' # Wealth distributions can include negatives
#' wealth <- c(-5000, 0, 5000, 20000, 80000, 250000, 1e6)
#' iq_compare(wealth, negatives = "keep")
iq_compare <- function(x, weights = NULL, na.rm = FALSE,
                       ci = FALSE, R = 1000L, level = 0.95,
                       negatives = c("error", "keep")) {
  negatives <- match.arg(negatives)
  v <- validate_inputs(x, weights, na.rm,
                       require_strictly_positive = (negatives == "error"),
                       negatives = negatives)
  xv <- v$x
  wv <- v$weights

  allow_log <- all(xv > 0)
  point <- .compare_point(xv, wv, allow_log = allow_log)
  measures <- names(point)
  values <- unname(point)

  tbl <- data.frame(
    measure = measures, value = values, stringsAsFactors = FALSE
  )

  if (ci) {
    n <- length(xv)
    alpha_lvl <- (1 - level) / 2
    boot <- replicate(R, {
      idx <- sample.int(n, size = n, replace = TRUE, prob = wv)
      xb <- xv[idx]
      .compare_point(xb, rep(1 / n, n), allow_log = all(xb > 0))
    })
    tbl$ci_lower <- apply(boot, 1, function(z) {
      z <- z[is.finite(z)]
      if (length(z) < 10L) NA_real_ else unname(quantile(z, alpha_lvl))
    })
    tbl$ci_upper <- apply(boot, 1, function(z) {
      z <- z[is.finite(z)]
      if (length(z) < 10L) NA_real_ else unname(quantile(z, 1 - alpha_lvl))
    })
  }

  structure(
    list(table = tbl, n = length(xv),
         level = if (ci) level else NULL),
    class = "iq_comparison"
  )
}

#' @noRd
.compare_point <- function(x, w, allow_log = TRUE) {
  ge_t <- if (allow_log) .ge_weighted(x, w, 1) else NA_real_
  ge_l <- if (allow_log) .ge_weighted(x, w, 0) else NA_real_
  atk_05 <- if (allow_log) .atkinson_weighted(x, w, 0.5) else NA_real_
  atk_10 <- if (allow_log) .atkinson_weighted(x, w, 1.0) else NA_real_
  c(
    "Gini"             = .gini_weighted(x, w),
    "S-Gini (delta=3)" = .sgini_weighted(x, w, 3),
    "Theil T (GE1)"    = ge_t,
    "Theil L (GE0)"    = ge_l,
    "Atkinson (e=0.5)" = atk_05,
    "Atkinson (e=1.0)" = atk_10,
    "Kolm (a=1)"       = .kolm_weighted(x, w, 1),
    "Wolfson"          = .wolfson_components(x, w)$wolfson,
    "Palma ratio"      = .palma_components(x, w)$palma,
    "Hoover"           = .hoover_weighted(x, w),
    "P90/P10"          = .pratio(x, w, 0.9, 0.1),
    "P80/P20"          = .pratio(x, w, 0.8, 0.2)
  )
}

#' @noRd
.pratio <- function(x, w, upper, lower) {
  v <- weighted_quantile(x, w, c(lower, upper))
  if (v[1L] == 0) return(NA_real_)
  v[2L] / v[1L]
}

#' @export
print.iq_comparison <- function(x, ...) {
  cli_h1("Inequality Comparison (n = {x$n})")
  tbl <- x$table
  has_ci <- !is.null(tbl$ci_lower)
  max_name <- max(nchar(tbl$measure))
  for (i in seq_len(nrow(tbl))) {
    label <- formatC(tbl$measure[i], width = max_name, flag = "-")
    val_str <- if (is.na(tbl$value[i])) "      NA" else
      formatC(round(tbl$value[i], 4), format = "f", digits = 4, width = 8)
    line <- paste(label, val_str)
    if (has_ci && is.finite(tbl$ci_lower[i])) {
      line <- paste0(line, "  [", round(tbl$ci_lower[i], 4),
                     ", ", round(tbl$ci_upper[i], 4), "]")
    }
    cli_bullets(c("*" = line))
  }
  if (has_ci) {
    cli_bullets(c("i" = "Bootstrap {round(x$level * 100)}% CIs in brackets."))
  }
  if (any(is.na(tbl$value))) {
    cli_bullets(c("!" = "Rows with {.val NA} are undefined for the input (e.g. Theil and Atkinson require strictly positive values)."))
  }
  invisible(x)
}
