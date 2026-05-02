#' Kakwani progressivity index
#'
#' Measures the progressivity of a tax or transfer system. A positive value
#' indicates progressivity (the rich pay a larger share than their income
#' share); a negative value indicates regressivity. Zero means proportional.
#'
#' The Kakwani index equals the concentration coefficient of the tax minus
#' the pre-tax Gini coefficient: K = C_T - G_pre.
#'
#' The post-tax Gini is computed on `pre_tax - tax` directly. Households
#' whose post-tax income is negative are kept as-is, so the post-tax Gini
#' may exceed 1 in distributions with extreme tax burdens. Pass
#' `negatives = "error"` to abort on negative pre-tax incomes.
#'
#' @param pre_tax Numeric vector of pre-tax incomes (non-negative by default).
#' @param tax Numeric vector of tax payments (same length as `pre_tax`).
#'   Positive values are taxes paid; negative values are transfers received.
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap confidence intervals on the
#'   Kakwani and Reynolds-Smolensky indices? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#' @param negatives Character. `"error"` (default) aborts on negative
#'   pre-tax incomes; `"keep"` permits them.
#'
#' @return An S3 object of class `"iq_kakwani"` with elements:
#' \describe{
#'   \item{kakwani}{Numeric. The Kakwani index (-1 to 1).}
#'   \item{gini_pre}{Numeric. The pre-tax Gini coefficient.}
#'   \item{concentration_tax}{Numeric. The concentration coefficient of taxes.}
#'   \item{reynolds_smolensky}{Numeric. The Reynolds-Smolensky index
#'     (pre-tax Gini minus post-tax Gini).}
#'   \item{gini_post}{Numeric. The post-tax Gini coefficient.}
#'   \item{avg_tax_rate}{Numeric. Average effective tax rate.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{kakwani_ci, rs_ci}{Lists with `lower` and `upper` (or `NULL`).}
#' }
#'
#' @references
#' Kakwani, N. C. (1977). "Measurement of Tax Progressivity: An
#' International Comparison." \emph{The Economic Journal}, 87(345), 71--80.
#'
#' Reynolds, M. and Smolensky, E. (1977). \emph{Public Expenditures, Taxes,
#' and the Distribution of Income}. New York: Academic Press.
#'
#' @export
#' @examples
#' set.seed(1)
#' pre <- iq_sample_data("income")$income
#' # Progressive tax: higher rate for higher incomes
#' tax <- pre * (0.10 + 0.15 * (pre / max(pre)))
#' iq_kakwani(pre, tax)
#'
#' # With bootstrap CIs
#' iq_kakwani(pre, tax, ci = TRUE, R = 200)
iq_kakwani <- function(pre_tax, tax, weights = NULL, na.rm = FALSE,
                       ci = FALSE, R = 1000L, level = 0.95,
                       negatives = c("error", "keep")) {
  if (length(pre_tax) != length(tax)) {
    cli_abort("{.arg pre_tax} and {.arg tax} must have the same length.")
  }
  if (!is.numeric(tax)) {
    cli_abort("{.arg tax} must be a numeric vector.")
  }
  negatives <- match.arg(negatives)

  # Filter NAs jointly across pre_tax, tax, weights
  if (na.rm) {
    keep <- !is.na(pre_tax) & !is.na(tax)
    if (!is.null(weights)) keep <- keep & !is.na(weights)
    pre_tax <- pre_tax[keep]
    tax <- tax[keep]
    if (!is.null(weights)) weights <- weights[keep]
  } else {
    if (anyNA(tax)) {
      cli_abort("{.arg tax} contains {.val NA} values. Set {.code na.rm = TRUE} to remove them.")
    }
  }

  v <- validate_inputs(pre_tax, weights, na.rm = FALSE,
                       require_positive = TRUE, negatives = negatives)
  pre <- v$x
  w <- v$weights
  # Re-align tax to whatever validate_inputs may have done. Since na.rm was
  # applied above and validate_inputs is called with na.rm = FALSE, no further
  # filtering happens here.

  res <- .kakwani_components(pre, tax, w)

  ci_block <- list(kakwani = NULL, rs = NULL)
  if (ci) {
    n <- length(pre)
    alpha_lvl <- (1 - level) / 2
    boot <- replicate(R, {
      idx <- sample.int(n, size = n, replace = TRUE, prob = w)
      r <- .kakwani_components(pre[idx], tax[idx], rep(1 / n, n))
      c(r$kakwani, r$reynolds_smolensky)
    })
    k_vals <- boot[1, ]
    k_vals <- k_vals[is.finite(k_vals)]
    rs_vals <- boot[2, ]
    rs_vals <- rs_vals[is.finite(rs_vals)]
    if (length(k_vals) >= 10L) {
      ci_block$kakwani <- list(lower = unname(quantile(k_vals, alpha_lvl)),
                               upper = unname(quantile(k_vals, 1 - alpha_lvl)))
    }
    if (length(rs_vals) >= 10L) {
      ci_block$rs <- list(lower = unname(quantile(rs_vals, alpha_lvl)),
                          upper = unname(quantile(rs_vals, 1 - alpha_lvl)))
    }
  }

  structure(
    list(kakwani = res$kakwani, gini_pre = res$gini_pre,
         concentration_tax = res$concentration_tax,
         reynolds_smolensky = res$reynolds_smolensky,
         gini_post = res$gini_post,
         avg_tax_rate = res$avg_tax_rate,
         n = length(pre),
         kakwani_ci = ci_block$kakwani,
         rs_ci = ci_block$rs,
         level = if (ci) level else NULL),
    class = "iq_kakwani"
  )
}

#' @noRd
.kakwani_components <- function(pre, tax, w) {
  post <- pre - tax
  gini_pre <- .gini_weighted(pre, w)
  # Use the raw post-tax income, not abs(post). For households pushed below
  # zero, the post-tax Gini is computed honestly via the weighted formula and
  # may exceed 1.
  gini_post <- .gini_weighted(post, w)

  ord <- order(pre)
  tax_sorted <- tax[ord]
  w_sorted <- w[ord]
  mu_tax <- sum(w_sorted * tax_sorted)

  if (mu_tax == 0) {
    return(list(kakwani = NA_real_, gini_pre = gini_pre,
                concentration_tax = NA_real_, reynolds_smolensky = 0,
                gini_post = gini_post, avg_tax_rate = 0))
  }

  cum_w <- cumsum(w_sorted)
  frac_rank <- cum_w - w_sorted / 2
  conc_tax <- 2 / mu_tax * sum(w_sorted * tax_sorted * frac_rank) - 1

  list(
    kakwani = conc_tax - gini_pre,
    gini_pre = gini_pre,
    concentration_tax = conc_tax,
    reynolds_smolensky = gini_pre - gini_post,
    gini_post = gini_post,
    avg_tax_rate = mu_tax / sum(w * pre)
  )
}

#' @export
print.iq_kakwani <- function(x, ...) {
  prog <- if (is.na(x$kakwani)) "Undefined" else if (x$kakwani > 0.01) "Progressive" else if (x$kakwani < -0.01) "Regressive" else "Proportional"
  cli_h1("Fiscal Progressivity ({prog})")
  cli_bullets(c(
    "*" = "Kakwani index: {.val {round(x$kakwani, 4)}}",
    "*" = "Reynolds-Smolensky index: {.val {round(x$reynolds_smolensky, 4)}}",
    "*" = "Pre-tax Gini: {.val {round(x$gini_pre, 4)}}",
    "*" = "Post-tax Gini: {.val {round(x$gini_post, 4)}}",
    "*" = "Tax concentration coefficient: {.val {round(x$concentration_tax, 4)}}",
    "*" = "Average tax rate: {.val {round(x$avg_tax_rate * 100, 1)}}%",
    "*" = "Observations: {.val {x$n}}"
  ))
  if (!is.null(x$kakwani_ci)) {
    cli_bullets(c(
      "*" = "Bootstrap {round(x$level * 100)}% CIs:",
      " " = "Kakwani: [{round(x$kakwani_ci$lower, 4)}, {round(x$kakwani_ci$upper, 4)}]",
      " " = "Reynolds-Smolensky: [{round(x$rs_ci$lower, 4)}, {round(x$rs_ci$upper, 4)}]"
    ))
  }
  invisible(x)
}
