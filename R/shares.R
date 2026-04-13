#' Income shares by quantile
#'
#' Computes the share of total income held by each segment of the
#' distribution. Default segments: bottom 50%, middle 40%, top 10%,
#' and top 1%.
#'
#' @param x Numeric vector of incomes (non-negative).
#' @param weights Optional numeric vector of survey weights.
#' @param breaks Numeric vector of cumulative population thresholds
#'   defining the segments. Default `c(0.50, 0.90, 0.99, 1.00)`.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_shares"` with elements:
#' \describe{
#'   \item{shares}{data.frame with columns `segment`, `pop_share`,
#'     `income_share`.}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_shares(d$income)
#'
#' # Custom breaks: quintiles
#' iq_shares(d$income, breaks = c(0.20, 0.40, 0.60, 0.80, 1.00))
iq_shares <- function(x, weights = NULL,
                      breaks = c(0.50, 0.90, 0.99, 1.00),
                      na.rm = FALSE) {
  if (any(breaks <= 0) || any(breaks > 1) || is.unsorted(breaks) ||
      breaks[length(breaks)] != 1) {
    cli_abort("{.arg breaks} must be sorted values in (0, 1] ending with 1.")
  }

  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w)
  total_income <- sum(w * x)

  lower_bounds <- c(0, breaks[-length(breaks)])
  upper_bounds <- breaks

  shares <- vapply(seq_along(breaks), function(i) {
    in_segment <- cum_w > lower_bounds[i] & cum_w <= upper_bounds[i]
    # Handle boundary observations with fractional weights
    sum(w[in_segment] * x[in_segment]) / total_income
  }, numeric(1))

  # Build segment labels
  labels <- vapply(seq_along(breaks), function(i) {
    lo <- round(lower_bounds[i] * 100)
    hi <- round(upper_bounds[i] * 100)
    if (lo == 0) paste0("Bottom ", hi, "%")
    else if (hi == 100) paste0("Top ", 100 - lo, "%")
    else paste0("P", lo, "-P", hi)
  }, character(1))

  pop_shares <- upper_bounds - lower_bounds

  shares_df <- data.frame(
    segment = labels,
    pop_share = pop_shares,
    income_share = shares,
    stringsAsFactors = FALSE
  )

  structure(list(shares = shares_df, n = length(x)), class = "iq_shares")
}

#' @export
print.iq_shares <- function(x, ...) {
  cli_h1("Income Shares")
  for (i in seq_len(nrow(x$shares))) {
    s <- x$shares[i, ]
    cli_bullets(c("*" = paste0(
      s$segment, ": ", round(s$income_share * 100, 1), "%",
      " of income (", round(s$pop_share * 100, 0), "% of population)"
    )))
  }
  cli_bullets(c("*" = "Observations: {.val {x$n}}"))
  invisible(x)
}
