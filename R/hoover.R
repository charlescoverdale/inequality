#' Hoover index (Robin Hood index)
#'
#' Computes the Hoover index, also known as the Robin Hood index or the
#' Schutz coefficient. It equals the maximum proportion of total income
#' that would need to be redistributed to achieve perfect equality, or
#' equivalently, half the mean absolute deviation divided by the mean.
#'
#' @param x Numeric vector of incomes (non-negative).
#' @param weights Optional numeric vector of survey weights.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_hoover"` with elements:
#' \describe{
#'   \item{value}{Numeric. The Hoover index (0 to 1).}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' iq_hoover(d$income)
#'
#' # Perfect equality
#' iq_hoover(rep(100, 50))
iq_hoover <- function(x, weights = NULL, na.rm = FALSE) {
  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  mu <- sum(w * x)
  if (mu == 0) return(structure(list(value = 0, n = length(x)), class = "iq_hoover"))

  # H = 0.5 * sum(w_i * |x_i/mu - 1|)
  value <- 0.5 * sum(w * abs(x / mu - 1))

  structure(list(value = value, n = length(x)), class = "iq_hoover")
}

#' @export
print.iq_hoover <- function(x, ...) {
  cli_h1("Hoover Index")
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  invisible(x)
}
