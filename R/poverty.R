#' Poverty measures
#'
#' Computes the Foster-Greer-Thorbecke (FGT) family of poverty measures,
#' plus the Sen index and the Watts index. All measures require a poverty
#' line.
#'
#' @param x Numeric vector of incomes (non-negative).
#' @param line Numeric. The poverty line. Required.
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_poverty"` with elements:
#' \describe{
#'   \item{headcount}{Numeric. FGT(0): proportion below the poverty line.}
#'   \item{gap}{Numeric. FGT(1): average normalised gap.}
#'   \item{severity}{Numeric. FGT(2): average squared normalised gap.}
#'   \item{sen}{Numeric. Sen index: headcount * (gap among poor +
#'     Gini among poor * (1 - gap among poor)).}
#'   \item{watts}{Numeric. Watts index: mean of log(line/x) among the poor.}
#'   \item{line}{Numeric. The poverty line used.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{n_poor}{Integer. Number of observations below the line.}
#' }
#'
#' @references
#' Foster, J., Greer, J. and Thorbecke, E. (1984). "A Class of Decomposable
#' Poverty Measures." \emph{Econometrica}, 52(3), 761--766.
#'
#' Sen, A. (1976). "Poverty: An Ordinal Approach to Measurement."
#' \emph{Econometrica}, 44(2), 219--231.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' # Poverty line at the 20th percentile
#' p20 <- quantile(d$income, 0.20)
#' iq_poverty(d$income, line = p20)
iq_poverty <- function(x, line, weights = NULL, na.rm = FALSE) {
  if (missing(line) || !is.numeric(line) || length(line) != 1L || line <= 0) {
    cli_abort("{.arg line} must be a single positive number.")
  }

  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  poor <- x < line
  n_poor <- sum(poor)

  if (n_poor == 0L) {
    return(structure(
      list(headcount = 0, gap = 0, severity = 0, sen = 0, watts = 0,
           line = line, n = length(x), n_poor = 0L),
      class = "iq_poverty"
    ))
  }

  gaps <- pmax((line - x) / line, 0)

  headcount <- sum(w[poor])
  gap_index <- sum(w * gaps)
  severity <- sum(w * gaps^2)

  # Sen index
  x_poor <- x[poor]
  w_poor <- w[poor] / sum(w[poor])
  gini_poor <- .gini_weighted(x_poor, w_poor)
  avg_gap_poor <- sum(w_poor * (line - x_poor)) / line
  sen <- headcount * (avg_gap_poor + gini_poor * (1 - avg_gap_poor))

  # Watts index
  watts <- sum(w[poor] * log(line / x[poor]))

  structure(
    list(headcount = headcount, gap = gap_index, severity = severity,
         sen = sen, watts = watts, line = line, n = length(x),
         n_poor = n_poor),
    class = "iq_poverty"
  )
}

#' @export
print.iq_poverty <- function(x, ...) {
  cli_h1("Poverty Measures (line = {round(x$line, 2)})")
  cli_bullets(c(
    "*" = "Headcount (FGT0): {.val {round(x$headcount * 100, 1)}}%",
    "*" = "Poverty gap (FGT1): {.val {round(x$gap, 4)}}",
    "*" = "Severity (FGT2): {.val {round(x$severity, 4)}}",
    "*" = "Sen index: {.val {round(x$sen, 4)}}",
    "*" = "Watts index: {.val {round(x$watts, 4)}}",
    "*" = "Poor: {.val {x$n_poor}} of {.val {x$n}} observations"
  ))
  invisible(x)
}
