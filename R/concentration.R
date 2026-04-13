#' Concentration index
#'
#' Computes the concentration index, which measures inequality in a health
#' (or other) variable across the income distribution. Unlike the Gini
#' coefficient, the ranking variable and the outcome variable are different.
#'
#' A positive value indicates the outcome is concentrated among the better-off;
#' a negative value indicates concentration among the worse-off. The index
#' ranges from -1 to 1.
#'
#' @param x Numeric vector of outcome values (e.g. health expenditure).
#' @param rank Numeric vector of ranking values (e.g. income). Must be the
#'   same length as `x`.
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_concentration"` with elements:
#' \describe{
#'   \item{value}{Numeric. The concentration index.}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @references
#' Wagstaff, A., Paci, P. and van Doorslaer, E. (1991). "On the Measurement
#' of Inequalities in Health." \emph{Social Science and Medicine}, 33(5),
#' 545--557.
#'
#' @export
#' @examples
#' set.seed(1)
#' income <- rlnorm(200, 10, 0.8)
#' health_exp <- income * 0.05 + rnorm(200, 500, 100)
#' iq_concentration(health_exp, rank = income)
iq_concentration <- function(x, rank, weights = NULL, na.rm = FALSE) {
  if (!is.numeric(rank)) {
    cli_abort("{.arg rank} must be a numeric vector.")
  }
  if (length(rank) != length(x)) {
    cli_abort("{.arg rank} must have the same length as {.arg x}.")
  }

  # Handle NAs in rank as well
  if (na.rm) {
    keep <- !is.na(x) & !is.na(rank)
    if (!is.null(weights)) keep <- keep & !is.na(weights)
    x <- x[keep]
    rank <- rank[keep]
    if (!is.null(weights)) weights <- weights[keep]
  } else {
    if (anyNA(rank)) cli_abort("{.arg rank} contains {.val NA} values.")
  }

  v <- validate_inputs(x, weights, na.rm = FALSE)
  x <- v$x
  w <- v$weights

  # Sort by rank

  ord <- order(rank)
  x <- x[ord]
  w <- w[ord]

  mu <- sum(w * x)
  if (mu == 0) {
    return(structure(list(value = 0, n = length(x)), class = "iq_concentration"))
  }

  cum_w <- cumsum(w)
  # Fractional rank: R_i = (cumw_{i-1} + w_i/2)
  frac_rank <- cum_w - w / 2

  # C = (2 / mu) * sum(w_i * x_i * R_i) - 1
  value <- 2 / mu * sum(w * x * frac_rank) - 1

  structure(list(value = value, n = length(x)), class = "iq_concentration")
}

#' @export
print.iq_concentration <- function(x, ...) {
  cli_h1("Concentration Index")
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  invisible(x)
}
