#' Atkinson index
#'
#' Computes the Atkinson inequality index, which incorporates an explicit
#' normative judgement about inequality aversion through the parameter
#' epsilon. Higher epsilon gives more weight to transfers at the bottom
#' of the distribution.
#'
#' @param x Numeric vector of incomes (strictly positive).
#' @param weights Optional numeric vector of survey weights.
#' @param epsilon Numeric. Inequality aversion parameter (> 0). Default `0.5`.
#'   Common values: 0.5 (moderate), 1.0 (high), 2.0 (very high aversion).
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_atkinson"` with elements:
#' \describe{
#'   \item{value}{Numeric. The Atkinson index (0 to 1).}
#'   \item{epsilon}{Numeric. The inequality aversion parameter used.}
#'   \item{ede}{Numeric. The equally distributed equivalent income.}
#'   \item{mean_income}{Numeric. The mean income.}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @references
#' Atkinson, A. B. (1970). "On the Measurement of Inequality."
#' \emph{Journal of Economic Theory}, 2(3), 244--263.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#'
#' # Moderate inequality aversion
#' iq_atkinson(d$income, epsilon = 0.5)
#'
#' # High inequality aversion
#' iq_atkinson(d$income, epsilon = 1)
#'
#' # Very high inequality aversion
#' iq_atkinson(d$income, epsilon = 2)
iq_atkinson <- function(x, weights = NULL, epsilon = 0.5, na.rm = FALSE) {
  if (!is.numeric(epsilon) || length(epsilon) != 1L || epsilon <= 0) {
    cli_abort("{.arg epsilon} must be a positive number.")
  }

  v <- validate_inputs(x, weights, na.rm, require_strictly_positive = TRUE)
  x <- v$x
  w <- v$weights

  mu <- sum(w * x)

  if (epsilon == 1) {
    # Limiting case: A = 1 - (prod(x_i^w_i)) / mu
    ede <- exp(sum(w * log(x)))
  } else {
    ede <- sum(w * x^(1 - epsilon))^(1 / (1 - epsilon))
  }

  value <- 1 - ede / mu

  structure(
    list(value = value, epsilon = epsilon, ede = ede, mean_income = mu,
         n = length(x)),
    class = "iq_atkinson"
  )
}

#' @export
print.iq_atkinson <- function(x, ...) {
  cli_h1("Atkinson Index")
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Epsilon: {.val {x$epsilon}}",
    "*" = "EDE income: {.val {round(x$ede, 2)}}",
    "*" = "Mean income: {.val {round(x$mean_income, 2)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  invisible(x)
}
