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
#' under perfect equality.
#'
#' @param x Numeric vector of incomes.
#' @param weights Optional numeric vector of survey weights.
#' @param alpha Numeric. Inequality aversion parameter (> 0). Default `1`.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_kolm"` with elements:
#' \describe{
#'   \item{value}{Numeric. The Kolm index.}
#'   \item{alpha}{Numeric. The inequality aversion parameter used.}
#'   \item{n}{Integer. Number of observations.}
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
#' # Higher aversion to inequality at the bottom
#' iq_kolm(d$income, alpha = 2)
iq_kolm <- function(x, weights = NULL, alpha = 1, na.rm = FALSE) {
  if (!is.numeric(alpha) || length(alpha) != 1L || alpha <= 0) {
    cli_abort("{.arg alpha} must be a positive number.")
  }

  v <- validate_inputs(x, weights, na.rm)
  x <- v$x
  w <- v$weights

  mu <- sum(w * x)
  # K(alpha) = (1/alpha) * log(sum(w_i * exp(alpha * (mu - x_i))))
  # Use log-sum-exp trick for numerical stability:
  # log(sum(w * exp(z))) = max(z) + log(sum(w * exp(z - max(z))))
  z <- alpha * (mu - x)
  z_max <- max(z)
  value <- (1 / alpha) * (z_max + log(sum(w * exp(z - z_max))))

  structure(
    list(value = value, alpha = alpha, n = length(x)),
    class = "iq_kolm"
  )
}

#' @export
print.iq_kolm <- function(x, ...) {
  cli_h1("Kolm Index (absolute inequality)")
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Alpha: {.val {x$alpha}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  invisible(x)
}
