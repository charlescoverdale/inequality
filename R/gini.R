#' Gini coefficient
#'
#' Computes the Gini coefficient of a distribution, with optional survey
#' weights and confidence intervals (bootstrap or asymptotic).
#'
#' The Gini coefficient ranges from 0 (perfect equality) to 1 (perfect
#' inequality). It equals twice the area between the Lorenz curve and
#' the 45-degree line.
#'
#' @param x Numeric vector of incomes or values (non-negative).
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute confidence intervals? Default `FALSE`.
#' @param method Character. CI method: `"bootstrap"` (default) or
#'   `"asymptotic"` (jackknife-based, faster for large samples).
#' @param R Integer. Number of bootstrap replicates (ignored for
#'   asymptotic). Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#'
#' @return An S3 object of class `"iq_gini"` with elements:
#' \describe{
#'   \item{gini}{Numeric. The Gini coefficient.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se}{Numeric or `NULL`. Standard error (asymptotic method only).}
#'   \item{ci_lower}{Numeric or `NULL`. Lower bound of the CI.}
#'   \item{ci_upper}{Numeric or `NULL`. Upper bound of the CI.}
#'   \item{level}{Numeric or `NULL`. Confidence level.}
#'   \item{method}{Character or `NULL`. CI method used.}
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
#' # Perfect equality
#' iq_gini(rep(100, 50))
iq_gini <- function(x, weights = NULL, na.rm = FALSE,
                    ci = FALSE, method = c("bootstrap", "asymptotic"),
                    R = 1000L, level = 0.95) {
  method <- match.arg(method)
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  gini_val <- .gini_weighted(x, w)

  ci_lower <- NULL
  ci_upper <- NULL
  se_val <- NULL

  if (ci) {
    z <- qnorm(1 - (1 - level) / 2)

    if (method == "bootstrap") {
      boot_vals <- replicate(R, {
        idx <- sample.int(length(x), replace = TRUE)
        .gini_weighted(x[idx], w[idx])
      })
      alpha <- (1 - level) / 2
      ci_lower <- unname(quantile(boot_vals, alpha))
      ci_upper <- unname(quantile(boot_vals, 1 - alpha))
      se_val <- sd(boot_vals)
    } else {
      # Asymptotic SE via jackknife (Davidson 2009 approach)
      n <- length(x)
      jack_vals <- vapply(seq_len(n), function(i) {
        .gini_weighted(x[-i], w[-i])
      }, numeric(1))
      # Jackknife variance: ((n-1)/n) * sum((jack_i - mean(jack))^2)
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
      method = if (ci) method else NULL
    ),
    class = "iq_gini"
  )
}

#' @noRd
.gini_weighted <- function(x, w) {
  # Normalise weights
  w <- w / sum(w)
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  mu <- sum(w * x)
  if (mu == 0) return(0)
  cum_w <- cumsum(w)
  # Gini = (2 / mu) * sum(w_i * x_i * (cum_w_i - w_i/2)) - 1
  sum(w * x * (cum_w - w / 2)) * 2 / mu - 1
}

#' @export
print.iq_gini <- function(x, ...) {
  cli_h1("Gini Coefficient")
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
  invisible(x)
}
