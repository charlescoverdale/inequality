#' Atkinson index
#'
#' Computes the Atkinson inequality index, which incorporates an explicit
#' normative judgement about inequality aversion through the parameter
#' epsilon. Higher epsilon gives more weight to transfers at the bottom
#' of the distribution.
#'
#' The Atkinson index involves either a power transformation
#' `x^(1 - epsilon)` or `log(x)` (when `epsilon = 1`) and so requires
#' strictly positive values. Use the Gini, S-Gini, or Kolm index for
#' distributions that include zeros or negatives.
#'
#' @param x Numeric vector of incomes (strictly positive).
#' @param weights Optional numeric vector of survey weights.
#' @param epsilon Numeric. Inequality aversion parameter (> 0). Default `0.5`.
#'   Common values: 0.5 (moderate), 1.0 (high), 2.0 (very high aversion).
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap confidence intervals? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#'
#' @return An S3 object of class `"iq_atkinson"` with elements:
#' \describe{
#'   \item{value}{Numeric. The Atkinson index (0 to 1).}
#'   \item{epsilon}{Numeric. The inequality aversion parameter used.}
#'   \item{ede}{Numeric. The equally distributed equivalent income.}
#'   \item{mean_income}{Numeric. The mean income.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se, ci_lower, ci_upper, level}{Bootstrap CI fields, `NULL` unless
#'     `ci = TRUE`.}
#' }
#'
#' @references
#' Atkinson, A. B. (1970). "On the Measurement of Inequality."
#' \emph{Journal of Economic Theory}, 2(3), 244--263.
#'
#' Biewen, M. and Jenkins, S. P. (2006). "Variance Estimation for
#' Generalized Entropy and Atkinson Inequality Indices: The Complex
#' Survey Data Case." \emph{Oxford Bulletin of Economics and Statistics},
#' 68(3), 371--383.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#'
#' # Moderate inequality aversion
#' iq_atkinson(d$income, epsilon = 0.5)
#'
#' # With bootstrap CIs
#' iq_atkinson(d$income, epsilon = 0.5, ci = TRUE, R = 200)
#'
#' # High inequality aversion
#' iq_atkinson(d$income, epsilon = 1)
#'
#' # Very high inequality aversion
#' iq_atkinson(d$income, epsilon = 2)
iq_atkinson <- function(x, weights = NULL, epsilon = 0.5, na.rm = FALSE,
                        ci = FALSE, R = 1000L, level = 0.95) {
  if (!is.numeric(epsilon) || length(epsilon) != 1L || epsilon <= 0) {
    cli_abort("{.arg epsilon} must be a positive number.")
  }

  v <- validate_inputs(x, weights, na.rm, require_strictly_positive = TRUE)
  x <- v$x
  w <- v$weights

  stat_fn <- function(x, w) .atkinson_weighted(x, w, epsilon)
  value <- stat_fn(x, w)

  mu <- sum(w * x)
  if (epsilon == 1) {
    ede <- exp(sum(w * log(x)))
  } else {
    ede <- sum(w * x^(1 - epsilon))^(1 / (1 - epsilon))
  }

  ci_block <- if (ci) .bootstrap_ci(stat_fn, x, w, R = R, level = level)
              else list(se = NULL, ci_lower = NULL, ci_upper = NULL, level = NULL)

  structure(
    list(value = value, epsilon = epsilon, ede = ede, mean_income = mu,
         n = length(x),
         se = ci_block$se,
         ci_lower = ci_block$ci_lower,
         ci_upper = ci_block$ci_upper,
         level = if (ci) level else NULL),
    class = "iq_atkinson"
  )
}

#' @noRd
.atkinson_weighted <- function(x, w, epsilon) {
  mu <- sum(w * x)
  if (epsilon == 1) {
    ede <- exp(sum(w * log(x)))
  } else {
    ede <- sum(w * x^(1 - epsilon))^(1 / (1 - epsilon))
  }
  1 - ede / mu
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
  if (!is.null(x$ci_lower)) {
    cli_bullets(c(
      "*" = "Bootstrap {round(x$level * 100)}% CI: [{.val {round(x$ci_lower, 4)}}, {.val {round(x$ci_upper, 4)}}]"
    ))
  }
  invisible(x)
}
