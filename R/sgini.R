#' S-Gini (extended Gini family)
#'
#' Computes the S-Gini coefficient, a one-parameter generalisation of the
#' Gini that allows the user to specify how much weight to give different
#' parts of the distribution. The standard Gini is the special case
#' `delta = 2`.
#'
#' Lower delta (approaching 1) gives equal weight everywhere; higher delta
#' gives more weight to the bottom of the distribution. The standard Gini
#' (delta = 2) weights by rank position. Delta = 3 or 4 places even more
#' emphasis on the poorest.
#'
#' @param x Numeric vector of incomes (non-negative).
#' @param weights Optional numeric vector of survey weights.
#' @param delta Numeric. Inequality aversion parameter (> 1). Default `2`
#'   (standard Gini).
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_sgini"` with elements:
#' \describe{
#'   \item{value}{Numeric. The S-Gini coefficient.}
#'   \item{delta}{Numeric. The inequality aversion parameter used.}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @references
#' Donaldson, D. and Weymark, J. A. (1980). "A Single-Parameter
#' Generalization of the Gini Indices of Inequality."
#' \emph{Journal of Economic Theory}, 22(1), 67--86.
#'
#' Yitzhaki, S. (1983). "On an Extension of the Gini Inequality Index."
#' \emph{International Economic Review}, 24(3), 617--628.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#'
#' # Standard Gini (delta = 2)
#' iq_sgini(d$income, delta = 2)
#'
#' # More weight on the bottom of the distribution
#' iq_sgini(d$income, delta = 3)
iq_sgini <- function(x, weights = NULL, delta = 2, na.rm = FALSE) {
  if (!is.numeric(delta) || length(delta) != 1L || delta <= 1) {
    cli_abort("{.arg delta} must be a number greater than 1.")
  }

  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  mu <- sum(w * x)
  if (mu == 0) return(structure(list(value = 0, delta = delta, n = length(x)),
                                class = "iq_sgini"))

  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w)

  # S-Gini via covariance formula (Yitzhaki 1983):
  # SG(delta) = 1 - (1/mu) * delta * sum(w_i * x_i * (1 - F_i)^(delta-1))
  # where F_i = cumw_i - w_i/2 (midpoint of the CDF step)
  frac_rank <- cum_w - w / 2
  survival <- 1 - frac_rank
  value <- 1 - (delta / mu) * sum(w * x * survival^(delta - 1))

  # At delta=2 this should equal the standard Gini
  structure(
    list(value = value, delta = delta, n = length(x)),
    class = "iq_sgini"
  )
}

#' @export
print.iq_sgini <- function(x, ...) {
  label <- if (x$delta == 2) "S-Gini (standard Gini, delta = 2)" else paste0("S-Gini (delta = ", x$delta, ")")
  cli_h1(label)
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  invisible(x)
}
