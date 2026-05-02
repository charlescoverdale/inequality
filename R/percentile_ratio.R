#' Percentile ratio
#'
#' Computes the ratio of two percentiles of the distribution. Common
#' choices include P90/P10 (interdecile ratio), P80/P20, and P50/P10.
#'
#' @param x Numeric vector of incomes.
#' @param weights Optional numeric vector of survey weights.
#' @param upper Numeric. Upper percentile (0 to 100). Default `90`.
#' @param lower Numeric. Lower percentile (0 to 100). Default `10`.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap confidence intervals? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#'
#' @return An S3 object of class `"iq_percentile_ratio"` with elements:
#' \describe{
#'   \item{ratio}{Numeric. The percentile ratio.}
#'   \item{upper_value}{Numeric. The value at the upper percentile.}
#'   \item{lower_value}{Numeric. The value at the lower percentile.}
#'   \item{upper}{Numeric. The upper percentile used.}
#'   \item{lower}{Numeric. The lower percentile used.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se, ci_lower, ci_upper, level}{Bootstrap CI fields, `NULL` unless
#'     `ci = TRUE`.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#'
#' # P90/P10 (interdecile ratio)
#' iq_percentile_ratio(d$income)
#'
#' # With bootstrap CIs
#' iq_percentile_ratio(d$income, ci = TRUE, R = 200)
#'
#' # P80/P20
#' iq_percentile_ratio(d$income, upper = 80, lower = 20)
iq_percentile_ratio <- function(x, weights = NULL, upper = 90, lower = 10,
                                na.rm = FALSE,
                                ci = FALSE, R = 1000L, level = 0.95) {
  if (upper <= lower) {
    cli_abort("{.arg upper} must be greater than {.arg lower}.")
  }
  if (upper > 100 || upper < 0 || lower > 100 || lower < 0) {
    cli_abort("Percentiles must be between 0 and 100.")
  }

  v <- validate_inputs(x, weights, na.rm)
  x <- v$x
  w <- v$weights

  probs <- c(lower, upper) / 100
  vals <- weighted_quantile(x, w, probs)

  if (vals[1L] == 0) {
    cli_abort("The P{lower} value is zero; the ratio is undefined.")
  }

  if (vals[1L] < 0) {
    cli::cli_warn(c(
      "P{lower} is negative ({.val {round(vals[1L], 2)}}); the resulting ratio sign-flips and has no inequality interpretation in the usual sense.",
      "i" = "Consider {.fun iq_gini} with {.code negatives = \"keep\"} or {.fun iq_kolm} for distributions containing negatives."
    ))
  }

  stat_fn <- function(x, w) {
    v2 <- weighted_quantile(x, w, probs)
    if (v2[1L] == 0) return(NA_real_)
    v2[2L] / v2[1L]
  }

  ci_block <- if (ci) .bootstrap_ci(stat_fn, x, w, R = R, level = level)
              else list(se = NULL, ci_lower = NULL, ci_upper = NULL, level = NULL)

  structure(
    list(ratio = vals[2L] / vals[1L], upper_value = vals[2L],
         lower_value = vals[1L], upper = upper, lower = lower,
         n = length(x),
         se = ci_block$se,
         ci_lower = ci_block$ci_lower,
         ci_upper = ci_block$ci_upper,
         level = if (ci) level else NULL),
    class = "iq_percentile_ratio"
  )
}

#' @export
print.iq_percentile_ratio <- function(x, ...) {
  cli_h1("Percentile Ratio (P{x$upper}/P{x$lower})")
  cli_bullets(c(
    "*" = "Ratio: {.val {round(x$ratio, 2)}}",
    "*" = "P{x$upper}: {.val {round(x$upper_value, 2)}}",
    "*" = "P{x$lower}: {.val {round(x$lower_value, 2)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  if (!is.null(x$ci_lower)) {
    cli_bullets(c(
      "*" = "Bootstrap {round(x$level * 100)}% CI: [{.val {round(x$ci_lower, 2)}}, {.val {round(x$ci_upper, 2)}}]"
    ))
  }
  invisible(x)
}
