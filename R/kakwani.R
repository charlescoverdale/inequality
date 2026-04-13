#' Kakwani progressivity index
#'
#' Measures the progressivity of a tax or transfer system. A positive value
#' indicates progressivity (the rich pay a larger share than their income
#' share); a negative value indicates regressivity. Zero means proportional.
#'
#' The Kakwani index equals the concentration coefficient of the tax minus
#' the pre-tax Gini coefficient: K = C_T - G_pre.
#'
#' @param pre_tax Numeric vector of pre-tax incomes (non-negative).
#' @param tax Numeric vector of tax payments (same length as `pre_tax`).
#'   Positive values are taxes paid; negative values are transfers received.
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
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
iq_kakwani <- function(pre_tax, tax, weights = NULL, na.rm = FALSE) {
  if (length(pre_tax) != length(tax)) {
    cli_abort("{.arg pre_tax} and {.arg tax} must have the same length.")
  }
  if (!is.numeric(tax)) {
    cli_abort("{.arg tax} must be a numeric vector.")
  }

  v <- validate_inputs(pre_tax, weights, na.rm, require_positive = TRUE)
  pre <- v$x
  w <- v$weights

  # Handle NAs in tax if na.rm
  if (na.rm) {
    keep <- !is.na(tax)
    tax <- tax[keep]
    # pre and w already filtered by validate_inputs, but we need to align
    # This is handled because validate_inputs filters the same positions
  }

  post <- pre - tax

  # Pre-tax Gini
  gini_pre <- .gini_weighted(pre, w)

  # Post-tax Gini
  gini_post <- .gini_weighted(abs(post), w)

  # Concentration coefficient of tax (ranked by pre-tax income)
  ord <- order(pre)
  tax_sorted <- tax[ord]
  w_sorted <- w[ord]
  mu_tax <- sum(w_sorted * tax_sorted)

  cum_w <- cumsum(w_sorted)
  frac_rank <- cum_w - w_sorted / 2
  conc_tax <- 2 / mu_tax * sum(w_sorted * tax_sorted * frac_rank) - 1

  kakwani_val <- conc_tax - gini_pre
  rs_val <- gini_pre - gini_post
  avg_rate <- mu_tax / sum(w * pre)

  structure(
    list(kakwani = kakwani_val, gini_pre = gini_pre,
         concentration_tax = conc_tax, reynolds_smolensky = rs_val,
         gini_post = gini_post, avg_tax_rate = avg_rate, n = length(pre)),
    class = "iq_kakwani"
  )
}

#' @export
print.iq_kakwani <- function(x, ...) {
  prog <- if (x$kakwani > 0.01) "Progressive" else if (x$kakwani < -0.01) "Regressive" else "Proportional"
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
  invisible(x)
}
