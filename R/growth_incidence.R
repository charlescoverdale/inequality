#' Growth incidence curve
#'
#' Computes the growth incidence curve (GIC), showing the annualised or
#' total growth rate at each quantile of the distribution between two
#' time periods.
#'
#' If the GIC is upward-sloping, the rich grew faster and inequality
#' increased. If downward-sloping, growth was pro-poor.
#'
#' @param x_t0 Numeric vector of incomes in period 0.
#' @param x_t1 Numeric vector of incomes in period 1. Must be the same
#'   length as `x_t0`.
#' @param weights_t0 Optional weights for period 0.
#' @param weights_t1 Optional weights for period 1.
#' @param n_quantiles Integer. Number of quantile bins. Default `20`
#'   (ventiles).
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_growth_incidence"` with elements:
#' \describe{
#'   \item{gic}{data.frame with columns `quantile` (midpoint), `growth`
#'     (proportional growth rate at that quantile).}
#'   \item{mean_growth}{Numeric. Mean growth across all quantiles.}
#'   \item{median_growth}{Numeric. Median growth rate.}
#'   \item{n_quantiles}{Integer.}
#' }
#'
#' @references
#' Ravallion, M. and Chen, S. (2003). "Measuring Pro-Poor Growth."
#' \emph{Economics Letters}, 78(1), 93--99.
#'
#' @export
#' @examples
#' d <- iq_sample_data("panel")
#' gic <- iq_growth_incidence(d$income_t0, d$income_t1)
#' plot(gic)
iq_growth_incidence <- function(x_t0, x_t1, weights_t0 = NULL,
                                weights_t1 = NULL, n_quantiles = 20L,
                                na.rm = FALSE) {
  if (length(x_t0) != length(x_t1)) {
    cli_abort("{.arg x_t0} and {.arg x_t1} must have the same length.")
  }

  v0 <- validate_inputs(x_t0, weights_t0, na.rm, require_strictly_positive = TRUE)
  v1 <- validate_inputs(x_t1, weights_t1, na.rm, require_strictly_positive = TRUE)

  probs <- seq(0, 1, length.out = n_quantiles + 1L)
  q0 <- weighted_quantile(v0$x, v0$weights, probs)
  q1 <- weighted_quantile(v1$x, v1$weights, probs)

  # Growth at each quantile midpoint
  midpoints <- (probs[-1L] + probs[-length(probs)]) / 2
  growth <- (q1[-1L] - q0[-1L]) / q0[-1L]

  gic_df <- data.frame(quantile = midpoints, growth = growth)

  structure(
    list(gic = gic_df, mean_growth = mean(growth),
         median_growth = median(growth), n_quantiles = n_quantiles),
    class = "iq_growth_incidence"
  )
}

#' @export
print.iq_growth_incidence <- function(x, ...) {
  cli_h1("Growth Incidence Curve")
  cli_bullets(c(
    "*" = "Quantiles: {.val {x$n_quantiles}}",
    "*" = "Mean growth: {.val {round(x$mean_growth * 100, 2)}}%",
    "*" = "Median growth: {.val {round(x$median_growth * 100, 2)}}%",
    "*" = "Bottom decile growth: {.val {round(x$gic$growth[1] * 100, 2)}}%",
    "*" = "Top decile growth: {.val {round(x$gic$growth[nrow(x$gic)] * 100, 2)}}%"
  ))
  invisible(x)
}

#' @export
plot.iq_growth_incidence <- function(x, ...) {
  old_par <- par(mar = c(4.5, 4.5, 3, 1))
  on.exit(par(old_par))

  plot(x$gic$quantile * 100, x$gic$growth * 100,
       type = "l", lwd = 2, col = "black",
       xlab = "Percentile", ylab = "Growth rate (%)",
       main = "Growth Incidence Curve", ...)

  abline(h = x$mean_growth * 100, lty = 2, col = "grey50")
  grid(col = "grey90")

  legend("topright",
         legend = c("GIC", paste0("Mean (", round(x$mean_growth * 100, 1), "%)")),
         lty = c(1, 2), lwd = c(2, 1), col = c("black", "grey50"),
         bty = "n", cex = 0.9)

  invisible(x)
}
