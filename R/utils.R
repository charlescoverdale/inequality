# Internal helpers — not exported

# Validate and prepare inputs shared across all functions
validate_inputs <- function(x, weights = NULL, na.rm = FALSE,
                            require_positive = FALSE,
                            require_strictly_positive = FALSE) {
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

  if (require_positive && any(x < 0)) {
    cli_abort("{.arg x} must be non-negative for this index.")
  }
  if (require_strictly_positive && any(x <= 0)) {
    cli_abort("{.arg x} must be strictly positive for this index.")
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
