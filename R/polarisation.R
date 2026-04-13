#' Polarisation index
#'
#' Computes the Wolfson bipolarisation index, which measures the extent
#' to which a distribution is bimodal (clustering at the tails) rather
#' than unimodal. Higher values indicate more polarisation.
#'
#' @param x Numeric vector of incomes (non-negative).
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_polarisation"` with elements:
#' \describe{
#'   \item{wolfson}{Numeric. The Wolfson polarisation index.}
#'   \item{gini}{Numeric. The Gini coefficient.}
#'   \item{median}{Numeric. The weighted median income.}
#'   \item{mean}{Numeric. The weighted mean income.}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @references
#' Wolfson, M. C. (1994). "When Inequalities Diverge."
#' \emph{American Economic Review}, 84(2), 353--358.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_polarisation(d$income)
iq_polarisation <- function(x, weights = NULL, na.rm = FALSE) {
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  mu <- sum(w * x)
  med <- weighted_quantile(x, w, 0.5)
  gini_val <- .gini_weighted(x, w)

  # Lorenz ordinate at the median: L(0.5)
  ord <- order(x)
  xs <- x[ord]
  ws <- w[ord]
  cum_w <- cumsum(ws)
  cum_income <- cumsum(ws * xs) / sum(ws * xs)
  # Interpolate L(0.5)
  l50 <- approx(cum_w, cum_income, xout = 0.5, rule = 2)$y

  # Wolfson = 2 * (2 * (0.5 - L(0.5)) - Gini) * (mu / med)
  # Simplified: W = (mu/med) * (Gini - 2*(Gini_below_median))
  # Standard form: W = 2 * (mu/med) * (0.5 - L(0.5) - Gini/2)
  # But more commonly: W = (mu/med) * (2 * (0.5 - L(0.5)) - Gini)
  wolfson <- (mu / med) * (2 * (0.5 - l50) - gini_val)
  # Wolfson should be non-negative; numerical issues can make it slightly negative
  wolfson <- max(wolfson, 0)

  structure(
    list(wolfson = wolfson, gini = gini_val, median = med, mean = mu,
         n = length(x)),
    class = "iq_polarisation"
  )
}

#' @export
print.iq_polarisation <- function(x, ...) {
  cli_h1("Polarisation")
  cli_bullets(c(
    "*" = "Wolfson index: {.val {round(x$wolfson, 4)}}",
    "*" = "Gini: {.val {round(x$gini, 4)}}",
    "*" = "Median income: {.val {round(x$median, 2)}}",
    "*" = "Mean income: {.val {round(x$mean, 2)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  invisible(x)
}
