#' Lorenz curve
#'
#' Computes the Lorenz curve: the cumulative share of income held by the
#' cumulative share of the population, ordered from poorest to richest.
#' The result can be plotted with `plot()`.
#'
#' @param x Numeric vector of incomes (non-negative).
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_lorenz"` with elements:
#' \describe{
#'   \item{curve}{data.frame with columns `cum_pop` and `cum_income`
#'     (both 0 to 1). Starts at (0, 0) and ends at (1, 1).}
#'   \item{gini}{Numeric. The Gini coefficient (twice the area between
#'     the curve and the diagonal).}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @references
#' Lorenz, M. O. (1905). "Methods of Measuring the Concentration of
#' Wealth." \emph{Publications of the American Statistical Association},
#' 9(70), 209--219.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' lc <- iq_lorenz(d$income)
#' plot(lc)
iq_lorenz <- function(x, weights = NULL, na.rm = FALSE) {
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  ord <- order(x)
  x <- x[ord]
  w <- w[ord]

  cum_pop <- c(0, cumsum(w))
  cum_income <- c(0, cumsum(w * x) / sum(w * x))

  gini_val <- .gini_weighted(x, w)

  structure(
    list(
      curve = data.frame(cum_pop = cum_pop, cum_income = cum_income),
      gini = gini_val,
      n = length(x)
    ),
    class = "iq_lorenz"
  )
}

#' @export
print.iq_lorenz <- function(x, ...) {
  cli_h1("Lorenz Curve")
  cli_bullets(c(
    "*" = "Observations: {.val {x$n}}",
    "*" = "Gini coefficient: {.val {round(x$gini, 4)}}"
  ))
  invisible(x)
}

#' @export
plot.iq_lorenz <- function(x, ...) {
  curve_data <- x$curve
  old_par <- par(mar = c(4.5, 4.5, 3, 1))
  on.exit(par(old_par))

  plot(curve_data$cum_pop, curve_data$cum_income,
       type = "n", xlim = c(0, 1), ylim = c(0, 1),
       xlab = "Cumulative population share",
       ylab = "Cumulative income share",
       main = "Lorenz Curve", ...)

  # Shaded area between diagonal and curve
  polygon(
    c(curve_data$cum_pop, rev(curve_data$cum_pop)),
    c(curve_data$cum_pop, rev(curve_data$cum_income)),
    col = adjustcolor("grey70", alpha.f = 0.3), border = NA
  )

  # 45-degree line (perfect equality)
  lines(c(0, 1), c(0, 1), lty = 2, col = "grey50")

  # Lorenz curve
  lines(curve_data$cum_pop, curve_data$cum_income, lwd = 2, col = "black")

  grid(col = "grey90")

  legend("topleft",
         legend = paste0("Gini = ", round(x$gini, 4)),
         bty = "n", cex = 0.9)

  invisible(x)
}
