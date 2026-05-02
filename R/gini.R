#' Gini coefficient
#'
#' Computes the Gini coefficient of a distribution, with optional survey
#' weights and confidence intervals (bootstrap or asymptotic).
#'
#' For a strictly non-negative distribution the Gini ranges from 0 (perfect
#' equality) to 1 (perfect inequality) and equals twice the area between the
#' Lorenz curve and the 45-degree line.
#'
#' Following feedback from Cowell and Flachaire (personal communication, 2026)
#' the package permits negative values via `negatives = "keep"`. Two policies
#' are then available:
#'
#' - `normalised = FALSE` (default): the standard formula is applied. With
#'   negatives present the index is no longer bounded in the unit interval.
#'   When the population mean is non-positive the Gini has no inequality
#'   interpretation and the function returns `NA` with a warning.
#' - `normalised = TRUE`: the Raffinetti, Siletti and Vernizzi (2017)
#'   normalised Gini, which rescales the index back into the unit interval
#'   for distributions containing negatives. The denominator is replaced
#'   by `mean(|x|)` so the index is well-defined whenever any observation
#'   is non-zero.
#'
#' @param x Numeric vector of incomes or values.
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute confidence intervals? Default `FALSE`.
#' @param method Character. CI method: `"bootstrap"` (default) or
#'   `"asymptotic"` (jackknife-based, faster for large samples).
#' @param R Integer. Number of bootstrap replicates (ignored for
#'   asymptotic). Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#' @param negatives Character. `"error"` (default) aborts when `x` contains
#'   negative values; `"keep"` permits negatives.
#' @param normalised Logical. Use the Raffinetti, Siletti and Vernizzi (2017)
#'   normalised Gini? Default `FALSE`. Only meaningful when `negatives = "keep"`.
#'
#' @return An S3 object of class `"iq_gini"` with elements:
#' \describe{
#'   \item{gini}{Numeric. The Gini coefficient (or `NA` when undefined).}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se}{Numeric or `NULL`. Standard error.}
#'   \item{ci_lower}{Numeric or `NULL`. Lower bound of the CI.}
#'   \item{ci_upper}{Numeric or `NULL`. Upper bound of the CI.}
#'   \item{level}{Numeric or `NULL`. Confidence level.}
#'   \item{method}{Character or `NULL`. CI method used.}
#'   \item{has_negatives}{Logical. Whether the input contained negatives.}
#'   \item{normalised}{Logical. Whether the Raffinetti et al. normalisation
#'     was applied.}
#' }
#'
#' @references
#' Gini, C. (1912). "Variabilita e mutabilita." Reprinted in
#' \emph{Memorie di metodologica statistica} (Ed. Pizetti E, Salvemini, T).
#' Rome: Libreria Eredi Virgilio Veschi.
#'
#' Davidson, R. (2009). "Reliable Inference for the Gini Index."
#' \emph{Journal of Econometrics}, 150(1), 30--40.
#'
#' Raffinetti, E., Siletti, E. and Vernizzi, A. (2017). "Analyzing the
#' Effects of Negative and Non-negative Values on Income Inequality:
#' Evidence from the Survey of Household Income and Wealth of the Bank
#' of Italy (2012)." \emph{Social Indicators Research}, 133(1), 185--207.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_gini(d$income)
#'
#' # Bootstrap CIs
#' iq_gini(d$income, ci = TRUE, R = 500)
#'
#' # Asymptotic CIs (faster for large samples)
#' iq_gini(d$income, ci = TRUE, method = "asymptotic")
#'
#' # Wealth distributions can include negative net worth
#' wealth <- c(-5000, -1000, 0, 5000, 20000, 80000, 250000)
#' iq_gini(wealth, negatives = "keep")
#'
#' # Same data with the Raffinetti et al. (2017) normalisation
#' iq_gini(wealth, negatives = "keep", normalised = TRUE)
#'
#' # Perfect equality
#' iq_gini(rep(100, 50))
iq_gini <- function(x, weights = NULL, na.rm = FALSE,
                    ci = FALSE, method = c("bootstrap", "asymptotic"),
                    R = 1000L, level = 0.95,
                    negatives = c("error", "keep"),
                    normalised = FALSE) {
  method <- match.arg(method)
  negatives <- match.arg(negatives)
  if (!is.logical(normalised) || length(normalised) != 1L) {
    cli_abort("{.arg normalised} must be a single logical value.")
  }
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE,
                       negatives = negatives)
  x <- v$x
  w <- v$weights

  has_neg <- any(x < 0)
  stat_fn <- function(x, w) .gini_weighted(x, w, normalised = normalised)
  gini_val <- stat_fn(x, w)

  if (has_neg && !normalised && is.na(gini_val)) {
    cli::cli_warn("Population mean is non-positive; the standard Gini is undefined. Returning NA. Try {.code normalised = TRUE} for the Raffinetti et al. (2017) normalised Gini.")
  }

  ci_lower <- NULL
  ci_upper <- NULL
  se_val <- NULL

  if (ci) {
    if (method == "bootstrap") {
      b <- .bootstrap_ci(stat_fn, x, w, R = R, level = level)
      ci_lower <- b$ci_lower
      ci_upper <- b$ci_upper
      se_val <- b$se
    } else {
      # Asymptotic SE via jackknife (Davidson 2009 approach)
      z <- qnorm(1 - (1 - level) / 2)
      n <- length(x)
      jack_vals <- vapply(seq_len(n), function(i) {
        stat_fn(x[-i], w[-i] / sum(w[-i]))
      }, numeric(1))
      jack_mean <- mean(jack_vals)
      se_val <- sqrt((n - 1) / n * sum((jack_vals - jack_mean)^2))
      ci_lower <- gini_val - z * se_val
      ci_upper <- gini_val + z * se_val
    }
  }

  structure(
    list(
      gini = gini_val,
      n = length(x),
      se = se_val,
      ci_lower = ci_lower,
      ci_upper = ci_upper,
      level = if (ci) level else NULL,
      method = if (ci) method else NULL,
      has_negatives = has_neg,
      normalised = normalised
    ),
    class = "iq_gini"
  )
}

#' @noRd
.gini_weighted <- function(x, w, normalised = FALSE) {
  w <- w / sum(w)
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  mu <- sum(w * x)
  if (mu == 0 && !normalised) return(NA_real_)
  cum_w <- cumsum(w)
  num <- sum(w * x * (cum_w - w / 2)) * 2 - mu

  if (normalised) {
    # Raffinetti, Siletti and Vernizzi (2017): replace |mu| by mean(|x|).
    # When all observations are zero the index is exactly 0.
    denom <- sum(w * abs(x))
    if (denom == 0) return(0)
    return(num / denom)
  }

  if (mu < 0) return(NA_real_)
  num / mu
}

#' @export
print.iq_gini <- function(x, ...) {
  label <- if (isTRUE(x$normalised)) "Gini Coefficient (Raffinetti et al. normalised)" else "Gini Coefficient"
  cli_h1(label)
  cli_bullets(c(
    "*" = "Gini: {.val {round(x$gini, 4)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  if (!is.null(x$ci_lower)) {
    ci_label <- if (x$method == "asymptotic") "Asymptotic" else "Bootstrap"
    cli_bullets(c(
      "*" = "{ci_label} {round(x$level * 100)}% CI: [{.val {round(x$ci_lower, 4)}}, {.val {round(x$ci_upper, 4)}}]"
    ))
  }
  if (isTRUE(x$has_negatives) && !isTRUE(x$normalised)) {
    cli_bullets(c("!" = "Input contains negative values; the standard Gini is not bounded in the unit interval."))
  }
  invisible(x)
}
