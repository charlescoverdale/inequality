#' Polarisation index
#'
#' Computes the Wolfson bipolarisation index, which measures the extent
#' to which a distribution is bimodal (clustering at the tails) rather
#' than unimodal. Higher values indicate more polarisation.
#'
#' @param x Numeric vector of incomes.
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap confidence intervals? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#' @param negatives Character. `"error"` (default) aborts on negatives;
#'   `"keep"` permits them.
#'
#' @return An S3 object of class `"iq_polarisation"` with elements:
#' \describe{
#'   \item{wolfson}{Numeric. The Wolfson polarisation index.}
#'   \item{gini}{Numeric. The Gini coefficient.}
#'   \item{median}{Numeric. The weighted median income.}
#'   \item{mean}{Numeric. The weighted mean income.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se, ci_lower, ci_upper, level}{Bootstrap CI fields, `NULL` unless
#'     `ci = TRUE`.}
#' }
#'
#' @references
#' Wolfson, M. C. (1994). "When Inequalities Diverge."
#' \emph{American Economic Review}, 84(2), 353--358.
#'
#' Foster, J. E. and Wolfson, M. C. (2010). "Polarization and the Decline
#' of the Middle Class: Canada and the US." \emph{Journal of Economic
#' Inequality}, 8(2), 247--273.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_polarisation(d$income)
#'
#' # With bootstrap CIs
#' iq_polarisation(d$income, ci = TRUE, R = 200)
iq_polarisation <- function(x, weights = NULL, na.rm = FALSE,
                            ci = FALSE, R = 1000L, level = 0.95,
                            negatives = c("error", "keep")) {
  negatives <- match.arg(negatives)
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE,
                       negatives = negatives)
  x <- v$x
  w <- v$weights

  res <- .wolfson_components(x, w)

  stat_fn <- function(x, w) .wolfson_components(x, w)$wolfson
  ci_block <- if (ci) .bootstrap_ci(stat_fn, x, w, R = R, level = level)
              else list(se = NULL, ci_lower = NULL, ci_upper = NULL, level = NULL)

  structure(
    list(wolfson = res$wolfson, gini = res$gini, median = res$median,
         mean = res$mean, n = length(x),
         se = ci_block$se,
         ci_lower = ci_block$ci_lower,
         ci_upper = ci_block$ci_upper,
         level = if (ci) level else NULL),
    class = "iq_polarisation"
  )
}

#' @noRd
.wolfson_components <- function(x, w) {
  mu <- sum(w * x)
  med <- weighted_quantile(x, w, 0.5)
  gini_val <- .gini_weighted(x, w)

  if (!isTRUE(med > 0)) {
    return(list(wolfson = NA_real_, gini = gini_val, median = med, mean = mu))
  }

  ord <- order(x)
  xs <- x[ord]
  ws <- w[ord]
  cum_w <- cumsum(ws)
  total <- sum(ws * xs)
  if (!isTRUE(total > 0)) {
    return(list(wolfson = NA_real_, gini = gini_val, median = med, mean = mu))
  }
  cum_income <- cumsum(ws * xs) / total
  l50 <- approx(cum_w, cum_income, xout = 0.5, rule = 2)$y

  wolfson <- (mu / med) * (2 * (0.5 - l50) - gini_val)
  wolfson <- max(wolfson, 0)

  list(wolfson = wolfson, gini = gini_val, median = med, mean = mu)
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
  if (!is.null(x$ci_lower)) {
    cli_bullets(c(
      "*" = "Bootstrap {round(x$level * 100)}% CI: [{.val {round(x$ci_lower, 4)}}, {.val {round(x$ci_upper, 4)}}]"
    ))
  }
  invisible(x)
}
