#' Theil index and generalised entropy measures
#'
#' Computes the Theil T index (GE(1)), Theil L / mean log deviation (GE(0)),
#' or a generalised entropy index GE(alpha) for any non-negative alpha.
#'
#' Generalised entropy indices are the only class of inequality measures that
#' are both decomposable by population subgroups and satisfy the transfer
#' principle. Higher values indicate more inequality.
#'
#' @param x Numeric vector of incomes (strictly positive).
#' @param weights Optional numeric vector of survey weights.
#' @param index Character or numeric. `"T"` for Theil T (GE(1)), `"L"` for
#'   mean log deviation (GE(0)), or a numeric value for GE(alpha). Default
#'   `"T"`.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_theil"` with elements:
#' \describe{
#'   \item{value}{Numeric. The index value.}
#'   \item{alpha}{Numeric. The alpha parameter used.}
#'   \item{index_name}{Character. Human-readable name of the index.}
#'   \item{n}{Integer. Number of observations.}
#' }
#'
#' @references
#' Theil, H. (1967). \emph{Economics and Information Theory}. Amsterdam:
#' North-Holland.
#'
#' Cowell, F. A. (2011). \emph{Measuring Inequality}. 3rd edition. Oxford
#' University Press.
#'
#' Shorrocks, A. F. (1980). "The Class of Additively Decomposable
#' Inequality Measures." \emph{Econometrica}, 48(3), 613--625.
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#'
#' # Theil T (GE(1))
#' iq_theil(d$income, index = "T")
#'
#' # Mean log deviation (GE(0))
#' iq_theil(d$income, index = "L")
#'
#' # GE(2) — half the squared coefficient of variation
#' iq_theil(d$income, index = 2)
iq_theil <- function(x, weights = NULL, index = "T", na.rm = FALSE) {
  v <- validate_inputs(x, weights, na.rm, require_strictly_positive = TRUE)
  x <- v$x
  w <- v$weights

  if (is.character(index)) {
    index <- match.arg(index, c("T", "L"))
    alpha <- if (index == "T") 1 else 0
    index_name <- if (index == "T") "Theil T (GE(1))" else "Theil L / Mean Log Deviation (GE(0))"
  } else {
    if (!is.numeric(index) || length(index) != 1L || index < 0) {
      cli_abort("{.arg index} must be {.val T}, {.val L}, or a non-negative number.")
    }
    alpha <- index
    index_name <- paste0("GE(", alpha, ")")
  }

  value <- .ge_weighted(x, w, alpha)

  structure(
    list(value = value, alpha = alpha, index_name = index_name, n = length(x)),
    class = "iq_theil"
  )
}

#' @noRd
.ge_weighted <- function(x, w, alpha) {
  mu <- sum(w * x)
  r <- x / mu

  if (alpha == 0) {
    # GE(0) = -sum(w * log(x/mu))
    return(-sum(w * log(r)))
  }
  if (alpha == 1) {
    # GE(1) = sum(w * (x/mu) * log(x/mu))
    return(sum(w * r * log(r)))
  }
  # General case: GE(alpha) = (1/(alpha*(alpha-1))) * (sum(w * (x/mu)^alpha) - 1)
  sum(w * (r^alpha - 1)) / (alpha * (alpha - 1))
}

#' @export
print.iq_theil <- function(x, ...) {
  cli_h1(x$index_name)
  cli_bullets(c(
    "*" = "Value: {.val {round(x$value, 4)}}",
    "*" = "Observations: {.val {x$n}}"
  ))
  invisible(x)
}
