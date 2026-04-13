#' Compare inequality measures
#'
#' Computes all major inequality indices on the same data and returns a
#' summary table for easy comparison.
#'
#' @param x Numeric vector of incomes (strictly positive for Theil and
#'   Atkinson; non-negative for Gini, Palma, Hoover).
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#' @param ci Logical. Compute bootstrap CIs for the Gini? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#'
#' @return An S3 object of class `"iq_comparison"` with elements:
#' \describe{
#'   \item{table}{data.frame with columns `measure` and `value`.}
#'   \item{gini_ci}{List with `lower` and `upper` (or `NULL`).}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_compare(d$income)
iq_compare <- function(x, weights = NULL, na.rm = FALSE, ci = FALSE,
                       R = 1000L) {
  v <- validate_inputs(x, weights, na.rm, require_strictly_positive = TRUE)
  xv <- v$x
  wv <- v$weights

  gini_obj <- iq_gini(xv, wv, ci = ci, R = R)
  theil_t <- iq_theil(xv, wv, index = "T")
  theil_l <- iq_theil(xv, wv, index = "L")
  atk_05 <- iq_atkinson(xv, wv, epsilon = 0.5)
  atk_10 <- iq_atkinson(xv, wv, epsilon = 1.0)
  palma_obj <- iq_palma(xv, wv)
  hoover_obj <- iq_hoover(xv, wv)
  p9010 <- iq_percentile_ratio(xv, wv, upper = 90, lower = 10)
  p8020 <- iq_percentile_ratio(xv, wv, upper = 80, lower = 20)

  tbl <- data.frame(
    measure = c("Gini", "Theil T (GE1)", "Theil L (GE0)",
                "Atkinson (e=0.5)", "Atkinson (e=1.0)",
                "Palma ratio", "Hoover", "P90/P10", "P80/P20"),
    value = c(gini_obj$gini, theil_t$value, theil_l$value,
              atk_05$value, atk_10$value,
              palma_obj$palma, hoover_obj$value,
              p9010$ratio, p8020$ratio),
    stringsAsFactors = FALSE
  )

  gini_ci <- if (ci) list(lower = gini_obj$ci_lower, upper = gini_obj$ci_upper) else NULL

  structure(
    list(table = tbl, gini_ci = gini_ci, n = length(xv)),
    class = "iq_comparison"
  )
}

#' @export
print.iq_comparison <- function(x, ...) {
  cli_h1("Inequality Comparison (n = {x$n})")
  tbl <- x$table
  max_name <- max(nchar(tbl$measure))
  for (i in seq_len(nrow(tbl))) {
    label <- formatC(tbl$measure[i], width = max_name, flag = "-")
    val <- formatC(round(tbl$value[i], 4), format = "f", digits = 4, width = 8)
    cli_bullets(c("*" = paste(label, val)))
  }
  if (!is.null(x$gini_ci)) {
    cli_bullets(c("i" = "Gini 95% CI: [{round(x$gini_ci$lower, 4)}, {round(x$gini_ci$upper, 4)}]"))
  }
  invisible(x)
}
