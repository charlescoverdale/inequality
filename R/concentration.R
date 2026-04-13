#' Concentration index
#'
#' Computes the concentration index, which measures inequality in a health
#' (or other) variable across the income distribution. Unlike the Gini
#' coefficient, the ranking variable and the outcome variable are different.
#'
#' A positive value indicates the outcome is concentrated among the better-off;
#' a negative value indicates concentration among the worse-off.
#'
#' For bounded variables (e.g. binary health indicators), the standard
#' concentration index has bounds that depend on the mean. Use
#' `correction = "erreygers"` for the Erreygers (2009) corrected index,
#' which has fixed bounds of -1 to 1 regardless of the mean.
#'
#' @param x Numeric vector of outcome values (e.g. health expenditure).
#' @param rank Numeric vector of ranking values (e.g. income). Must be the
#'   same length as `x`.
#' @param weights Optional numeric vector of survey weights.
#' @param correction Character. `"none"` (default) for the standard index,
#'   or `"erreygers"` for the Erreygers (2009) correction for bounded
#'   variables.
#' @param bounds Numeric vector of length 2 giving the lower and upper bounds
#'   of `x`. Required when `correction = "erreygers"`. Default `c(0, 1)`
#'   (suitable for binary or proportion variables).
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_concentration"` with elements:
#' \describe{
#'   \item{value}{Numeric. The concentration index.}
#'   \item{correction}{Character. The correction applied.}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @references
#' Wagstaff, A., Paci, P. and van Doorslaer, E. (1991). "On the Measurement
#' of Inequalities in Health." \emph{Social Science and Medicine}, 33(5),
#' 545--557.
#'
#' Erreygers, G. (2009). "Correcting the Concentration Index."
#' \emph{Journal of Health Economics}, 28(2), 504--515.
#'
#' @export
#' @examples
#' set.seed(1)
#' income <- rlnorm(200, 10, 0.8)
#' health_exp <- income * 0.05 + rnorm(200, 500, 100)
#' iq_concentration(health_exp, rank = income)
#'
#' # Binary outcome with Erreygers correction
#' sick <- as.numeric(income < median(income)) + rbinom(200, 1, 0.1)
#' sick <- pmin(sick, 1)
#' iq_concentration(sick, rank = income, correction = "erreygers")
iq_concentration <- function(x, rank, weights = NULL,
                             correction = c("none", "erreygers"),
                             bounds = c(0, 1), na.rm = FALSE) {
  correction <- match.arg(correction)

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
    return(structure(list(value = 0, correction = correction, n = length(x)),
                     class = "iq_concentration"))
  }

  cum_w <- cumsum(w)
  # Fractional rank: R_i = (cumw_{i-1} + w_i/2)
  frac_rank <- cum_w - w / 2

  # C = (2 / mu) * sum(w_i * x_i * R_i) - 1
  ci_val <- 2 / mu * sum(w * x * frac_rank) - 1

  if (correction == "erreygers") {
    # Erreygers: E = 4 * mu / (b - a) * C
    a <- bounds[1L]
    b <- bounds[2L]
    if (b <= a) cli_abort("{.arg bounds} must have bounds[2] > bounds[1].")
    ci_val <- 4 * mu / (b - a) * ci_val
  }

  structure(list(value = ci_val, correction = correction, n = length(x)),
            class = "iq_concentration")
}

#' @export
print.iq_concentration <- function(x, ...) {
  label <- if (x$correction == "erreygers") "Concentration Index (Erreygers)" else "Concentration Index"
  cli_h1(label)
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  invisible(x)
}
