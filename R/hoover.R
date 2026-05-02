#' Hoover index (Robin Hood index)
#'
#' Computes the Hoover index, also known as the Robin Hood index or the
#' Schutz coefficient. It equals the maximum proportion of total income
#' that would need to be redistributed to achieve perfect equality, or
#' equivalently, half the mean absolute deviation divided by the mean.
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
#' @return An S3 object of class `"iq_hoover"` with elements:
#' \describe{
#'   \item{value}{Numeric. The Hoover index (0 to 1 with non-negative input).}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se, ci_lower, ci_upper, level}{Bootstrap CI fields, `NULL` unless
#'     `ci = TRUE`.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_hoover(d$income)
#'
#' # With bootstrap CIs
#' iq_hoover(d$income, ci = TRUE, R = 200)
#'
#' # Perfect equality
#' iq_hoover(rep(100, 50))
iq_hoover <- function(x, weights = NULL, na.rm = FALSE,
                      ci = FALSE, R = 1000L, level = 0.95,
                      negatives = c("error", "keep")) {
  negatives <- match.arg(negatives)
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE,
                       negatives = negatives)
  x <- v$x
  w <- v$weights

  value <- .hoover_weighted(x, w)
  ci_block <- if (ci) .bootstrap_ci(.hoover_weighted, x, w, R = R, level = level)
              else list(se = NULL, ci_lower = NULL, ci_upper = NULL, level = NULL)

  structure(
    list(value = value, n = length(x),
         se = ci_block$se,
         ci_lower = ci_block$ci_lower,
         ci_upper = ci_block$ci_upper,
         level = if (ci) level else NULL),
    class = "iq_hoover"
  )
}

#' @noRd
.hoover_weighted <- function(x, w) {
  mu <- sum(w * x)
  if (mu == 0) return(0)
  0.5 * sum(w * abs(x / mu - 1))
}

#' @export
print.iq_hoover <- function(x, ...) {
  cli_h1("Hoover Index")
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  if (!is.null(x$ci_lower)) {
    cli_bullets(c(
      "*" = "Bootstrap {round(x$level * 100)}% CI: [{.val {round(x$ci_lower, 4)}}, {.val {round(x$ci_upper, 4)}}]"
    ))
  }
  invisible(x)
}
