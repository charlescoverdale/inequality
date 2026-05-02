#' Income shares by quantile
#'
#' Computes the share of total income held by each segment of the
#' distribution. Default segments: bottom 50%, middle 40%, top 10%,
#' and top 1%.
#'
#' Distributions containing negative values can produce shares that fall
#' outside the unit interval: the bottom segment may have a negative share
#' (it pulls total income down), and other segments may exceed 100% as a
#' result. The function returns the raw shares and emits a warning when
#' negatives are present so the user can interpret accordingly. If the
#' population total income is non-positive (so shares are not well-defined
#' at all), the function returns `NA` shares with a warning.
#'
#' @param x Numeric vector of incomes.
#' @param weights Optional numeric vector of survey weights.
#' @param breaks Numeric vector of cumulative population thresholds
#'   defining the segments. Default `c(0.50, 0.90, 0.99, 1.00)`.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap confidence intervals on each
#'   share? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#' @param negatives Character. `"error"` (default) aborts on negatives;
#'   `"keep"` permits them.
#'
#' @return An S3 object of class `"iq_shares"` with elements:
#' \describe{
#'   \item{shares}{data.frame with columns `segment`, `pop_share`,
#'     `income_share`, and (when `ci = TRUE`) `ci_lower` and `ci_upper`.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{level}{Numeric or `NULL`. Confidence level.}
#'   \item{has_negatives}{Logical. Whether the input contained negatives.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_shares(d$income)
#'
#' # With bootstrap CIs on each share
#' iq_shares(d$income, ci = TRUE, R = 200)
#'
#' # Custom breaks: quintiles
#' iq_shares(d$income, breaks = c(0.20, 0.40, 0.60, 0.80, 1.00))
#'
#' # Wealth distributions can include negative net worth
#' wealth <- c(-5000, -1000, 0, 5000, 20000, 80000, 250000, 1e6)
#' iq_shares(wealth, negatives = "keep")
iq_shares <- function(x, weights = NULL,
                      breaks = c(0.50, 0.90, 0.99, 1.00),
                      na.rm = FALSE,
                      ci = FALSE, R = 1000L, level = 0.95,
                      negatives = c("error", "keep")) {
  if (any(breaks <= 0) || any(breaks > 1) || is.unsorted(breaks) ||
      breaks[length(breaks)] != 1) {
    cli_abort("{.arg breaks} must be sorted values in (0, 1] ending with 1.")
  }
  negatives <- match.arg(negatives)

  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE,
                       negatives = negatives)
  x <- v$x
  w <- v$weights
  has_neg <- any(x < 0)

  shares <- .income_shares(x, w, breaks)

  if (any(is.na(shares))) {
    cli::cli_warn("Total income is non-positive; income shares are undefined.")
  } else if (has_neg) {
    cli::cli_warn("Input contains negatives; some income shares may fall outside [0, 1].")
  }

  lower_bounds <- c(0, breaks[-length(breaks)])
  upper_bounds <- breaks
  pop_shares <- upper_bounds - lower_bounds

  labels <- vapply(seq_along(breaks), function(i) {
    lo <- round(lower_bounds[i] * 100)
    hi <- round(upper_bounds[i] * 100)
    if (lo == 0) paste0("Bottom ", hi, "%")
    else if (hi == 100) paste0("Top ", 100 - lo, "%")
    else paste0("P", lo, "-P", hi)
  }, character(1))

  shares_df <- data.frame(
    segment = labels,
    pop_share = pop_shares,
    income_share = shares,
    stringsAsFactors = FALSE
  )

  if (ci) {
    n <- length(x)
    alpha_lvl <- (1 - level) / 2
    boot_mat <- replicate(R, {
      idx <- sample.int(n, size = n, replace = TRUE, prob = w)
      .income_shares(x[idx], rep(1 / n, n), breaks)
    })
    shares_df$ci_lower <- apply(boot_mat, 1, function(z) {
      z <- z[is.finite(z)]
      if (length(z) < 10L) NA_real_ else unname(quantile(z, alpha_lvl))
    })
    shares_df$ci_upper <- apply(boot_mat, 1, function(z) {
      z <- z[is.finite(z)]
      if (length(z) < 10L) NA_real_ else unname(quantile(z, 1 - alpha_lvl))
    })
  }

  structure(list(shares = shares_df, n = length(x),
                 level = if (ci) level else NULL,
                 has_negatives = has_neg),
            class = "iq_shares")
}

#' @noRd
.income_shares <- function(x, w, breaks) {
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w)
  total_income <- sum(w * x)
  lower_bounds <- c(0, breaks[-length(breaks)])
  upper_bounds <- breaks

  if (!isTRUE(total_income > 0)) {
    return(rep(NA_real_, length(breaks)))
  }

  vapply(seq_along(breaks), function(i) {
    in_segment <- cum_w > lower_bounds[i] & cum_w <= upper_bounds[i]
    sum(w[in_segment] * x[in_segment]) / total_income
  }, numeric(1))
}

#' @export
print.iq_shares <- function(x, ...) {
  cli_h1("Income Shares")
  has_ci <- !is.null(x$shares$ci_lower)
  for (i in seq_len(nrow(x$shares))) {
    s <- x$shares[i, ]
    body <- paste0(
      s$segment, ": ", round(s$income_share * 100, 1), "%",
      " of income (", round(s$pop_share * 100, 0), "% of population)"
    )
    if (has_ci && is.finite(s$ci_lower)) {
      body <- paste0(body,
                     " [", round(s$ci_lower * 100, 1), "%, ",
                     round(s$ci_upper * 100, 1), "%]")
    }
    cli_bullets(c("*" = body))
  }
  cli_bullets(c("*" = "Observations: {.val {x$n}}"))
  if (has_ci) {
    cli_bullets(c("*" = "Bootstrap {round(x$level * 100)}% CIs shown in brackets."))
  }
  if (isTRUE(x$has_negatives)) {
    cli_bullets(c("!" = "Input contains negatives; shares may fall outside [0, 1]."))
  }
  invisible(x)
}
