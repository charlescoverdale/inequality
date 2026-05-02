#' Kolm index (absolute inequality)
#'
#' Computes the Kolm index, the only standard inequality measure that is
#' translation-invariant (absolute). Adding the same amount to every
#' income leaves the index unchanged. All other indices in this package
#' are scale-invariant (relative): multiplying every income by the same
#' factor leaves them unchanged.
#'
#' Higher alpha gives more weight to inequality at the bottom of the
#' distribution. The index is always non-negative and equals zero only
#' under perfect equality. The Kolm index is well-defined for any real
#' values, including negatives.
#'
#' @param x Numeric vector of incomes.
#' @param weights Optional numeric vector of survey weights.
#' @param alpha Numeric. Inequality aversion parameter (> 0). Default `1`.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap confidence intervals? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#'
#' @return An S3 object of class `"iq_kolm"` with elements:
#' \describe{
#'   \item{value}{Numeric. The Kolm index.}
#'   \item{alpha}{Numeric. The inequality aversion parameter used.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se, ci_lower, ci_upper, level}{Bootstrap CI fields, `NULL` unless
#'     `ci = TRUE`.}
#' }
#'
#' @references
#' Kolm, S.-C. (1976). "Unequal Inequalities II."
#' \emph{Journal of Economic Theory}, 13(1), 82--111.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_kolm(d$income, alpha = 1)
#'
#' # With bootstrap CIs
#' iq_kolm(d$income, alpha = 1, ci = TRUE, R = 200)
#'
#' # Higher aversion to inequality at the bottom
#' iq_kolm(d$income, alpha = 2)
iq_kolm <- function(x, weights = NULL, alpha = 1, na.rm = FALSE,
                    ci = FALSE, R = 1000L, level = 0.95) {
  if (!is.numeric(alpha) || length(alpha) != 1L || alpha <= 0) {
    cli_abort("{.arg alpha} must be a positive number.")
  }

  v <- validate_inputs(x, weights, na.rm)
  x <- v$x
  w <- v$weights

  stat_fn <- function(x, w) .kolm_weighted(x, w, alpha)
  value <- stat_fn(x, w)

  ci_block <- if (ci) .bootstrap_ci(stat_fn, x, w, R = R, level = level)
              else list(se = NULL, ci_lower = NULL, ci_upper = NULL, level = NULL)

  structure(
    list(value = value, alpha = alpha, n = length(x),
         se = ci_block$se,
         ci_lower = ci_block$ci_lower,
         ci_upper = ci_block$ci_upper,
         level = if (ci) level else NULL),
    class = "iq_kolm"
  )
}

#' @noRd
.kolm_weighted <- function(x, w, alpha) {
  mu <- sum(w * x)
  z <- alpha * (mu - x)
  z_max <- max(z)
  (1 / alpha) * (z_max + log(sum(w * exp(z - z_max))))
}

#' @export
print.iq_kolm <- function(x, ...) {
  cli_h1("Kolm Index (absolute inequality)")
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Alpha: {.val {x$alpha}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  if (!is.null(x$ci_lower)) {
    cli_bullets(c(
      "*" = "Bootstrap {round(x$level * 100)}% CI: [{.val {round(x$ci_lower, 4)}}, {.val {round(x$ci_upper, 4)}}]"
    ))
  }
  invisible(x)
}
