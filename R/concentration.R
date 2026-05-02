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
#' concentration index has bounds that depend on the mean. Two corrections
#' are available:
#' - `correction = "erreygers"`: the Erreygers (2009) corrected index,
#'   `E = 4 * mu / (b - a) * C`, which has fixed bounds of -1 to 1.
#' - `correction = "wagstaff"`: the Wagstaff (2005) normalised index,
#'   `W = C / (1 - mu / b)` for variables bounded above at `b`, which is
#'   the standard normalisation in much of the health-economics
#'   literature.
#'
#' @param x Numeric vector of outcome values (e.g. health expenditure).
#' @param rank Numeric vector of ranking values (e.g. income). Must be the
#'   same length as `x`.
#' @param weights Optional numeric vector of survey weights.
#' @param correction Character. `"none"` (default) for the standard index;
#'   `"erreygers"` for the Erreygers (2009) bounded-variable correction;
#'   `"wagstaff"` for the Wagstaff (2005) normalised index.
#' @param bounds Numeric vector of length 2 giving the lower and upper bounds
#'   of `x`. Required when `correction = "erreygers"`. Default `c(0, 1)`
#'   (suitable for binary or proportion variables).
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap confidence intervals? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#'
#' @return An S3 object of class `"iq_concentration"` with elements:
#' \describe{
#'   \item{value}{Numeric. The concentration index.}
#'   \item{correction}{Character. The correction applied.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se, ci_lower, ci_upper, level}{Bootstrap CI fields, `NULL` unless
#'     `ci = TRUE`.}
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
#' Wagstaff, A. (2005). "The Bounds of the Concentration Index when the
#' Variable of Interest is Binary, with an Application to Immunization
#' Inequality." \emph{Health Economics}, 14(4), 429--432.
#'
#' @export
#' @examples
#' set.seed(1)
#' income <- rlnorm(200, 10, 0.8)
#' health_exp <- income * 0.05 + rnorm(200, 500, 100)
#' iq_concentration(health_exp, rank = income)
#'
#' # With bootstrap CIs
#' iq_concentration(health_exp, rank = income, ci = TRUE, R = 200)
#'
#' # Binary outcome with Erreygers correction
#' sick <- as.numeric(income < median(income)) + rbinom(200, 1, 0.1)
#' sick <- pmin(sick, 1)
#' iq_concentration(sick, rank = income, correction = "erreygers")
iq_concentration <- function(x, rank, weights = NULL,
                             correction = c("none", "erreygers", "wagstaff"),
                             bounds = c(0, 1), na.rm = FALSE,
                             ci = FALSE, R = 1000L, level = 0.95) {
  correction <- match.arg(correction)

  if (!is.numeric(rank)) {
    cli_abort("{.arg rank} must be a numeric vector.")
  }
  if (length(rank) != length(x)) {
    cli_abort("{.arg rank} must have the same length as {.arg x}.")
  }

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

  if (correction %in% c("erreygers", "wagstaff")) {
    a <- bounds[1L]
    b <- bounds[2L]
    if (b <= a) cli_abort("{.arg bounds} must have bounds[2] > bounds[1].")
  }

  stat_fn <- function(x_b, w_b, rank_b) {
    .concentration_weighted(x_b, w_b, rank_b, correction, bounds)
  }

  ci_val <- stat_fn(x, w, rank)

  ci_block <- list(se = NULL, ci_lower = NULL, ci_upper = NULL, level = NULL)
  if (ci) {
    n <- length(x)
    alpha_lvl <- (1 - level) / 2
    vals <- replicate(R, {
      idx <- sample.int(n, size = n, replace = TRUE, prob = w)
      stat_fn(x[idx], rep(1 / n, n), rank[idx])
    })
    vals <- vals[is.finite(vals)]
    if (length(vals) >= 10L) {
      ci_block <- list(se = sd(vals),
                       ci_lower = unname(quantile(vals, alpha_lvl)),
                       ci_upper = unname(quantile(vals, 1 - alpha_lvl)),
                       level = level)
    } else {
      ci_block <- list(se = NA_real_, ci_lower = NA_real_, ci_upper = NA_real_,
                       level = level)
    }
  }

  structure(list(value = ci_val, correction = correction, n = length(x),
                 se = ci_block$se,
                 ci_lower = ci_block$ci_lower,
                 ci_upper = ci_block$ci_upper,
                 level = if (ci) level else NULL),
            class = "iq_concentration")
}

#' @noRd
.concentration_weighted <- function(x, w, rank, correction, bounds) {
  ord <- order(rank)
  x <- x[ord]
  w <- w[ord]
  mu <- sum(w * x)
  if (mu == 0) return(0)
  cum_w <- cumsum(w)
  frac_rank <- cum_w - w / 2
  ci_val <- 2 / mu * sum(w * x * frac_rank) - 1
  if (correction == "erreygers") {
    a <- bounds[1L]
    b <- bounds[2L]
    ci_val <- 4 * mu / (b - a) * ci_val
  } else if (correction == "wagstaff") {
    a <- bounds[1L]
    b <- bounds[2L]
    # Wagstaff (2005): W = C / (1 - mu/b - (a/b - a/b))
    # For variables on [a, b], the standardised form is C / (1 - (mu - a) / (b - a)).
    # The most common case (a = 0) reduces to C / (1 - mu / b).
    denom <- 1 - (mu - a) / (b - a)
    if (denom == 0) return(NA_real_)
    ci_val <- ci_val / denom
  }
  ci_val
}

#' @export
print.iq_concentration <- function(x, ...) {
  label <- switch(x$correction,
    erreygers = "Concentration Index (Erreygers)",
    wagstaff  = "Concentration Index (Wagstaff)",
    "Concentration Index"
  )
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
  invisible(x)
}
