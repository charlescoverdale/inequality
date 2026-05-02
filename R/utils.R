# Internal helpers (not exported)

# Validate and prepare inputs shared across all functions.
#
# `negatives` controls how negative values are handled:
#   "error" - abort if any x < 0 (or x <= 0 when require_strictly_positive = TRUE)
#   "keep"  - permit negatives; the caller's formula decides what to do with them
#
# `require_positive` and `require_strictly_positive` are still respected when
# negatives = "error". When negatives = "keep" they are bypassed; the caller is
# responsible for producing sensible output (e.g. NA with a warning) where the
# index is undefined for non-positive support.
validate_inputs <- function(x, weights = NULL, na.rm = FALSE,
                            require_positive = FALSE,
                            require_strictly_positive = FALSE,
                            negatives = c("error", "keep")) {
  negatives <- match.arg(negatives)

  if (!is.numeric(x)) {
    cli_abort("{.arg x} must be a numeric vector.")
  }
  if (length(x) < 2L) {
    cli_abort("{.arg x} must have at least 2 observations.")
  }

  if (!is.null(weights)) {
    if (!is.numeric(weights)) {
      cli_abort("{.arg weights} must be a numeric vector.")
    }
    if (length(weights) != length(x)) {
      cli_abort("{.arg weights} must have the same length as {.arg x}.")
    }
    if (any(weights < 0, na.rm = TRUE)) {
      cli_abort("{.arg weights} must be non-negative.")
    }
  }

  # Handle NAs
  if (na.rm) {
    keep <- !is.na(x)
    if (!is.null(weights)) keep <- keep & !is.na(weights)
    x <- x[keep]
    if (!is.null(weights)) weights <- weights[keep]
  } else {
    if (anyNA(x)) cli_abort("{.arg x} contains {.val NA} values. Set {.code na.rm = TRUE} to remove them.")
    if (!is.null(weights) && anyNA(weights)) {
      cli_abort("{.arg weights} contains {.val NA} values. Set {.code na.rm = TRUE} to remove them.")
    }
  }

  if (length(x) < 2L) {
    cli_abort("Fewer than 2 non-missing observations remain after removing {.val NA}s.")
  }

  if (negatives == "error") {
    if (require_positive && any(x < 0)) {
      cli_abort("{.arg x} must be non-negative for this index. Set {.code negatives = \"keep\"} to permit negative values.")
    }
    if (require_strictly_positive && any(x <= 0)) {
      # No negatives = "keep" suggestion here: GE(0), GE(1), and Atkinson with
      # epsilon >= 1 are mathematically undefined for non-positive values, and
      # the wrappers do not expose a `negatives` argument. Direct the user to
      # measures that admit zero or negative support.
      cli_abort(c(
        "{.arg x} must be strictly positive for this index.",
        "i" = "Use {.fun iq_gini}, {.fun iq_sgini}, {.fun iq_kolm}, or {.fun iq_hoover} for distributions containing zero or negative values."
      ))
    }
  }

  # Normalise weights
  if (is.null(weights)) {
    weights <- rep(1 / length(x), length(x))
  } else {
    weights <- weights / sum(weights)
  }

  list(x = x, weights = weights)
}

# Weighted quantile using linear interpolation on the weighted ECDF
weighted_quantile <- function(x, weights, probs) {
  ord <- order(x)
  x <- x[ord]
  weights <- weights[ord]
  cum_w <- cumsum(weights)
  # Normalise to [0, 1]
  cum_w <- cum_w / cum_w[length(cum_w)]

  vapply(probs, function(p) {
    if (p <= cum_w[1L]) return(x[1L])
    if (p >= cum_w[length(cum_w)]) return(x[length(x)])
    i <- which(cum_w >= p)[1L]
    if (cum_w[i] == p || i == 1L) return(x[i])
    # Linear interpolation
    x_lo <- x[i - 1L]
    x_hi <- x[i]
    w_lo <- cum_w[i - 1L]
    w_hi <- cum_w[i]
    x_lo + (p - w_lo) / (w_hi - w_lo) * (x_hi - x_lo)
  }, numeric(1))
}

# Bootstrap confidence interval for any inequality statistic.
#
# stat_fn(x, w) must return a single numeric value. x and w arrive normalised
# (weights sum to 1). For survey-weighted data we use a probability-proportional
# resample: sample.int with prob = w gives Rao-Wu-style behaviour where heavier
# observations are drawn more often, which is the right thing for CIs that
# reflect the design weighting in the point estimate.
.bootstrap_ci <- function(stat_fn, x, w, R = 1000L, level = 0.95) {
  n <- length(x)
  alpha <- (1 - level) / 2

  vals <- replicate(R, {
    idx <- sample.int(n, size = n, replace = TRUE, prob = w)
    xb <- x[idx]
    wb <- rep(1 / n, n)
    stat_fn(xb, wb)
  })

  vals <- vals[is.finite(vals)]
  if (length(vals) < 10L) {
    return(list(se = NA_real_, ci_lower = NA_real_, ci_upper = NA_real_,
                level = level, method = "bootstrap"))
  }

  list(
    se = sd(vals),
    ci_lower = unname(quantile(vals, alpha)),
    ci_upper = unname(quantile(vals, 1 - alpha)),
    level = level,
    method = "bootstrap"
  )
}
