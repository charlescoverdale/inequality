#' Palma ratio
#'
#' Computes the Palma ratio: the share of total income received by the top
#' 10 percent divided by the share received by the bottom 40 percent.
#'
#' The Palma ratio is motivated by Palma's (2011) observation that the
#' "middle" 50 percent (deciles 5--9) tends to capture a remarkably stable
#' share of income across countries, so inequality is driven by what happens
#' at the tails. A Palma ratio of 1 means the top 10 percent and bottom 40
#' percent receive equal shares.
#'
#' Distributions containing negative values may produce a non-positive
#' bottom-40 share, in which case the Palma ratio is undefined. The
#' function returns `NA` with a warning rather than aborting.
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
#' @return An S3 object of class `"iq_palma"` with elements:
#' \describe{
#'   \item{palma}{Numeric. The Palma ratio.}
#'   \item{top10_share}{Numeric. Share of income held by the top 10 percent.}
#'   \item{bottom40_share}{Numeric. Share of income held by the bottom 40 percent.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{se, ci_lower, ci_upper, level}{Bootstrap CI fields, `NULL` unless
#'     `ci = TRUE`.}
#' }
#'
#' @references
#' Palma, J. G. (2011). "Homogeneous Middles vs. Heterogeneous Tails, and the
#' End of the 'Inverted-U': It's All About the Share of the Rich."
#' \emph{Development and Change}, 42(1), 87--153.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_palma(d$income)
#'
#' # With bootstrap CIs
#' iq_palma(d$income, ci = TRUE, R = 200)
#'
#' # Equal distribution: Palma = 0.25/0.40 = 0.625
#' iq_palma(rep(100, 100))
iq_palma <- function(x, weights = NULL, na.rm = FALSE,
                     ci = FALSE, R = 1000L, level = 0.95,
                     negatives = c("error", "keep")) {
  negatives <- match.arg(negatives)
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE,
                       negatives = negatives)
  x <- v$x
  w <- v$weights

  res <- .palma_components(x, w)
  if (is.na(res$palma)) {
    cli::cli_warn("Bottom 40% income share is non-positive; Palma ratio is undefined.")
  }

  stat_fn <- function(x, w) .palma_components(x, w)$palma
  ci_block <- if (ci) .bootstrap_ci(stat_fn, x, w, R = R, level = level)
              else list(se = NULL, ci_lower = NULL, ci_upper = NULL, level = NULL)

  structure(
    list(palma = res$palma,
         top10_share = res$top10_share,
         bottom40_share = res$bottom40_share,
         n = length(x),
         se = ci_block$se,
         ci_lower = ci_block$ci_lower,
         ci_upper = ci_block$ci_upper,
         level = if (ci) level else NULL),
    class = "iq_palma"
  )
}

#' @noRd
.palma_components <- function(x, w) {
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w)
  cum_income <- cumsum(w * x)
  total <- cum_income[length(cum_income)]

  if (!isTRUE(total > 0)) {
    return(list(palma = NA_real_, top10_share = NA_real_, bottom40_share = NA_real_))
  }

  lorenz_at <- function(p) {
    if (p <= 0) return(0)
    if (p >= 1) return(1)
    approx(cum_w, cum_income / total, xout = p, rule = 2)$y
  }

  bottom40_share <- lorenz_at(0.4)
  top10_share <- 1 - lorenz_at(0.9)

  if (!isTRUE(bottom40_share > 0)) {
    return(list(palma = NA_real_, top10_share = top10_share,
                bottom40_share = bottom40_share))
  }

  list(palma = top10_share / bottom40_share,
       top10_share = top10_share,
       bottom40_share = bottom40_share)
}

#' @export
print.iq_palma <- function(x, ...) {
  cli_h1("Palma Ratio")
  cli_bullets(c(
    "*" = "Palma ratio: {.val {round(x$palma, 4)}}",
    "*" = "Top 10% share: {.val {round(x$top10_share * 100, 1)}}%",
    "*" = "Bottom 40% share: {.val {round(x$bottom40_share * 100, 1)}}%",
    "*" = "Observations: {.val {x$n}}"
  ))
  if (!is.null(x$ci_lower)) {
    cli_bullets(c(
      "*" = "Bootstrap {round(x$level * 100)}% CI: [{.val {round(x$ci_lower, 4)}}, {.val {round(x$ci_upper, 4)}}]"
    ))
  }
  invisible(x)
}
