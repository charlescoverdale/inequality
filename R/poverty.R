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
#' @param ci Logical. Compute bootstrap confidence intervals on the
#'   headcount, gap, severity, and Sen indices? Default `FALSE`.
#' @param R Integer. Number of bootstrap replicates. Default `1000`.
#' @param level Numeric. Confidence level. Default `0.95`.
#'
#' @return An S3 object of class `"iq_poverty"` with elements:
#' \describe{
#'   \item{headcount}{Numeric. FGT(0): proportion below the poverty line.}
#'   \item{gap}{Numeric. FGT(1): average normalised gap.}
#'   \item{severity}{Numeric. FGT(2): average squared normalised gap.}
#'   \item{sen}{Numeric. Sen index.}
#'   \item{watts}{Numeric. Watts index.}
#'   \item{line}{Numeric. The poverty line used.}
#'   \item{n}{Integer. Number of observations.}
#'   \item{n_poor}{Integer. Number of observations below the line.}
#'   \item{ci}{Optional list of bootstrap CIs for the four standard FGT/Sen
#'     measures (each a list with `lower` and `upper`).}
#'   \item{level}{Numeric or `NULL`. Confidence level.}
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
#'
#' # With bootstrap CIs
#' iq_poverty(d$income, line = p20, ci = TRUE, R = 200)
iq_poverty <- function(x, line, weights = NULL, na.rm = FALSE,
                       ci = FALSE, R = 1000L, level = 0.95) {
  if (missing(line) || !is.numeric(line) || length(line) != 1L || line <= 0) {
    cli_abort("{.arg line} must be a single positive number.")
  }

  v <- validate_inputs(x, weights, na.rm, require_positive = TRUE)
  x <- v$x
  w <- v$weights

  res <- .poverty_components(x, w, line)
  if (isTRUE(res$watts_dropped > 0)) {
    cli::cli_warn(c(
      "Watts index drops {res$watts_dropped} observation{?s} with {.code x = 0} (log of {.code line / 0} is undefined).",
      "i" = "FGT measures and Sen index include all poor observations."
    ))
  }

  ci_block <- NULL
  if (ci) {
    n <- length(x)
    alpha_lvl <- (1 - level) / 2
    boot <- replicate(R, {
      idx <- sample.int(n, size = n, replace = TRUE, prob = w)
      r <- .poverty_components(x[idx], rep(1 / n, n), line)
      c(r$headcount, r$gap, r$severity, r$sen)
    })
    pick <- function(row) {
      v <- boot[row, ]
      v <- v[is.finite(v)]
      if (length(v) < 10L) list(lower = NA_real_, upper = NA_real_)
      else list(lower = unname(quantile(v, alpha_lvl)),
                upper = unname(quantile(v, 1 - alpha_lvl)))
    }
    ci_block <- list(headcount = pick(1), gap = pick(2),
                     severity = pick(3), sen = pick(4))
  }

  structure(
    list(headcount = res$headcount, gap = res$gap, severity = res$severity,
         sen = res$sen, watts = res$watts, line = line, n = length(x),
         n_poor = res$n_poor,
         ci = ci_block,
         level = if (ci) level else NULL),
    class = "iq_poverty"
  )
}

#' @noRd
.poverty_components <- function(x, w, line) {
  poor <- x < line
  n_poor <- sum(poor)

  if (n_poor == 0L) {
    return(list(headcount = 0, gap = 0, severity = 0, sen = 0, watts = 0,
                n_poor = 0L, watts_dropped = 0L))
  }

  gaps <- pmax((line - x) / line, 0)
  headcount <- sum(w[poor])
  gap_index <- sum(w * gaps)
  severity <- sum(w * gaps^2)

  x_poor <- x[poor]
  w_poor_raw <- w[poor]
  w_poor <- w_poor_raw / sum(w_poor_raw)
  gini_poor <- .gini_weighted(x_poor, w_poor)
  if (is.na(gini_poor)) gini_poor <- 0
  avg_gap_poor <- sum(w_poor * (line - x_poor)) / line
  sen <- headcount * (avg_gap_poor + gini_poor * (1 - avg_gap_poor))

  # Watts is undefined for x = 0 (log diverges). Drop those observations from
  # the Watts sum and report the count separately so the caller can warn.
  watts_drop <- x_poor <= 0
  watts_dropped <- sum(watts_drop)
  if (watts_dropped == n_poor) {
    watts <- NA_real_
  } else {
    watts <- sum(w_poor_raw[!watts_drop] * log(line / x_poor[!watts_drop]))
  }

  list(headcount = headcount, gap = gap_index, severity = severity,
       sen = sen, watts = watts, n_poor = n_poor,
       watts_dropped = watts_dropped)
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
  if (!is.null(x$ci)) {
    fmt <- function(name, ci) {
      paste0(name, " 95% CI: [",
             round(ci$lower, 4), ", ",
             round(ci$upper, 4), "]")
    }
    cli_bullets(c(
      "*" = paste0("Bootstrap ", round(x$level * 100), "% CIs:"),
      " " = fmt("Headcount", x$ci$headcount),
      " " = fmt("Gap", x$ci$gap),
      " " = fmt("Severity", x$ci$severity),
      " " = fmt("Sen", x$ci$sen)
    ))
  }
  invisible(x)
}
