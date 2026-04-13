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
#' @param x Numeric vector of incomes (non-negative).
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_palma"` with elements:
#' \describe{
#'   \item{palma}{Numeric. The Palma ratio.}
#'   \item{top10_share}{Numeric. Share of income held by the top 10 percent.}
#'   \item{bottom40_share}{Numeric. Share of income held by the bottom 40 percent.}
#'   \item{n}{Integer. Number of observations.}
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
#' # Equal distribution: Palma = 0.25/0.40 = 0.625
#' iq_palma(rep(100, 100))
iq_palma <- function(x, weights = NULL, na.rm = FALSE) {
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w)
  cum_income <- cumsum(w * x)
  total <- cum_income[length(cum_income)]

  # Lorenz interpolation: income share at population quantile p
  lorenz_at <- function(p) {
    if (p <= 0) return(0)
    if (p >= 1) return(1)
    approx(cum_w, cum_income / total, xout = p, rule = 2)$y
  }

  bottom40_share <- lorenz_at(0.4)
  top10_share <- 1 - lorenz_at(0.9)
  palma_val <- top10_share / bottom40_share

  structure(
    list(palma = palma_val, top10_share = top10_share,
         bottom40_share = bottom40_share, n = length(x)),
    class = "iq_palma"
  )
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
  invisible(x)
}
