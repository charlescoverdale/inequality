#' Between-within group decomposition
#'
#' Decomposes a generalised entropy index into a between-group component
#' (inequality due to differences in group means) and a within-group
#' component (inequality within each group). The decomposition is exact:
#' between + within = total.
#'
#' @param x Numeric vector of incomes (strictly positive).
#' @param group Factor or character vector identifying group membership.
#' @param weights Optional numeric vector of survey weights.
#' @param index Character or numeric. `"T"` for Theil T (GE(1)), `"L"` for
#'   mean log deviation (GE(0)), or a numeric alpha. Default `"T"`.
#' @param na.rm Logical. Remove `NA` values? Default `FALSE`.
#'
#' @return An S3 object of class `"iq_decomposition"` with elements:
#' \describe{
#'   \item{total}{Numeric. The total GE index.}
#'   \item{between}{Numeric. The between-group component.}
#'   \item{within}{Numeric. The within-group component.}
#'   \item{groups}{data.frame with columns `group`, `n`, `mean_income`,
#'     `pop_share`, `income_share`, `within_ge`.}
#'   \item{index_name}{Character. Name of the index used.}
#' }
#'
#' @references
#' Bourguignon, F. (1979). "Decomposable Income Inequality Measures."
#' \emph{Econometrica}, 47(4), 901--920.
#'
#' @export
#' @examples
#' d <- iq_sample_data("grouped")
#' iq_decompose(d$income, d$group)
iq_decompose <- function(x, group, weights = NULL, index = "T", na.rm = FALSE) {
  if (length(group) != length(x)) {
    cli_abort("{.arg group} must have the same length as {.arg x}.")
  }

  v <- validate_inputs(x, weights, na.rm, require_strictly_positive = TRUE)
  x <- v$x
  w <- v$weights

  if (is.character(index)) {
    index <- match.arg(index, c("T", "L"))
    alpha <- if (index == "T") 1 else 0
    index_name <- if (index == "T") "Theil T (GE(1))" else "Theil L (GE(0))"
  } else {
    alpha <- index
    index_name <- paste0("GE(", alpha, ")")
  }

  total <- .ge_weighted(x, w, alpha)
  mu <- sum(w * x)

  groups <- unique(group)
  group_stats <- lapply(groups, function(g) {
    idx <- group == g
    xg <- x[idx]
    wg <- w[idx]
    wg_norm <- wg / sum(wg)
    pop_share <- sum(wg)
    income_share <- sum(wg * xg) / mu
    mean_inc <- sum(wg_norm * xg)
    within_ge <- .ge_weighted(xg, wg_norm, alpha)
    list(group = g, n = sum(idx), mean_income = mean_inc,
         pop_share = pop_share, income_share = income_share,
         within_ge = within_ge)
  })

  group_df <- data.frame(
    group = vapply(group_stats, `[[`, character(1), "group"),
    n = vapply(group_stats, `[[`, integer(1), "n"),
    mean_income = vapply(group_stats, `[[`, numeric(1), "mean_income"),
    pop_share = vapply(group_stats, `[[`, numeric(1), "pop_share"),
    income_share = vapply(group_stats, `[[`, numeric(1), "income_share"),
    within_ge = vapply(group_stats, `[[`, numeric(1), "within_ge"),
    stringsAsFactors = FALSE
  )

  # Within component: weighted sum of group GE values
  if (alpha == 0) {
    within <- sum(group_df$pop_share * group_df$within_ge)
  } else if (alpha == 1) {
    within <- sum(group_df$income_share * group_df$within_ge)
  } else {
    s <- group_df$pop_share
    y <- group_df$income_share
    within <- sum(s^(1 - alpha) * y^alpha * group_df$within_ge)
  }

  between <- total - within

  structure(
    list(total = total, between = between, within = within,
         groups = group_df, index_name = index_name),
    class = "iq_decomposition"
  )
}

#' @export
print.iq_decomposition <- function(x, ...) {
  cli_h1("Between-Within Decomposition ({x$index_name})")
  cli_bullets(c(
    "*" = "Total: {.val {round(x$total, 4)}}",
    "*" = "Between: {.val {round(x$between, 4)}} ({round(x$between / x$total * 100, 1)}%)",
    "*" = "Within: {.val {round(x$within, 4)}} ({round(x$within / x$total * 100, 1)}%)"
  ))
  cli_h2("Group Detail")
  for (i in seq_len(nrow(x$groups))) {
    g <- x$groups[i, ]
    cli_bullets(c("*" = paste0(
      g$group, ": n=", g$n,
      ", mean=", round(g$mean_income, 0),
      ", pop=", round(g$pop_share * 100, 1), "%",
      ", income=", round(g$income_share * 100, 1), "%"
    )))
  }
  invisible(x)
}
