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
#' Like the standard Gini, the S-Gini is well-defined for distributions
#' containing negative values via `negatives = "keep"`, though the
#' resulting index is no longer bounded in the unit interval.
#'
#' @param x Numeric vector of incomes.
#' @param weights Optional numeric vector of survey weights.
#' @param delta Numeric. Inequality aversion parameter (> 1). Default `2`
#'   (standard Gini).
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap confidence intervals? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#' @param negatives Character. `"error"` (default) aborts on negatives;
#'   `"keep"` permits them.
#'
#' @return An S3 object of class `"iq_sgini"` with elements:
#' \describe{
#'   \item{value}{Numeric. The S-Gini coefficient.}
#'   \item{delta}{Numeric. The inequality aversion parameter used.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se, ci_lower, ci_upper, level}{Bootstrap CI fields, `NULL` unless
#'     `ci = TRUE`.}
#'   \item{has_negatives}{Logical. Whether the input contained negatives.}
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
#'
#' # With bootstrap CIs
#' iq_sgini(d$income, delta = 3, ci = TRUE, R = 200)
iq_sgini <- function(x, weights = NULL, delta = 2, na.rm = FALSE,
                     ci = FALSE, R = 1000L, level = 0.95,
                     negatives = c("error", "keep")) {
  if (!is.numeric(delta) || length(delta) != 1L || delta <= 1) {
    cli_abort("{.arg delta} must be a number greater than 1.")
  }
  negatives <- match.arg(negatives)

  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE,
                       negatives = negatives)
  x <- v$x
  w <- v$weights

  has_neg <- any(x < 0)
  stat_fn <- function(x, w) .sgini_weighted(x, w, delta)
  value <- stat_fn(x, w)

  ci_block <- if (ci) .bootstrap_ci(stat_fn, x, w, R = R, level = level)
              else list(se = NULL, ci_lower = NULL, ci_upper = NULL, level = NULL)

  structure(
    list(value = value, delta = delta, n = length(x),
         se = ci_block$se,
         ci_lower = ci_block$ci_lower,
         ci_upper = ci_block$ci_upper,
         level = if (ci) level else NULL,
         has_negatives = has_neg),
    class = "iq_sgini"
  )
}

#' @noRd
.sgini_weighted <- function(x, w, delta) {
  mu <- sum(w * x)
  if (mu <= 0) return(NA_real_)
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w)
  frac_rank <- cum_w - w / 2
  survival <- 1 - frac_rank
  1 - (delta / mu) * sum(w * x * survival^(delta - 1))
}

#' @export
print.iq_sgini <- function(x, ...) {
  label <- if (x$delta == 2) "S-Gini (standard Gini, delta = 2)" else paste0("S-Gini (delta = ", x$delta, ")")
  cli_h1(label)
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  if (!is.null(x$ci_lower)) {
    cli_bullets(c(
      "*" = "Bootstrap {round(x$level * 100)}% CI: [{.val {round(x$ci_lower, 4)}}, {.val {round(x$ci_upper, 4)}}]"
    ))
  }
  if (isTRUE(x$has_negatives)) {
    cli_bullets(c("!" = "Input contains negative values; the S-Gini is not bounded in [0, 1]."))
  }
  invisible(x)
}
