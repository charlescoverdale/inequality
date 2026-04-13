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
#'
#' @return An S3 object of class `"iq_percentile_ratio"` with elements:
#' \describe{
#'   \item{ratio}{Numeric. The percentile ratio.}
#'   \item{upper_value}{Numeric. The value at the upper percentile.}
#'   \item{lower_value}{Numeric. The value at the lower percentile.}
#'   \item{upper}{Numeric. The upper percentile used.}
#'   \item{lower}{Numeric. The lower percentile used.}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#'
#' # P90/P10 (interdecile ratio)
#' iq_percentile_ratio(d$income)
#'
#' # P80/P20
#' iq_percentile_ratio(d$income, upper = 80, lower = 20)
iq_percentile_ratio <- function(x, weights = NULL, upper = 90, lower = 10,
                                na.rm = FALSE) {
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

  structure(
    list(ratio = vals[2L] / vals[1L], upper_value = vals[2L],
         lower_value = vals[1L], upper = upper, lower = lower,
         n = length(x)),
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
  invisible(x)
}
