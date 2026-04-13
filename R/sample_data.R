#' Generate sample inequality data
#'
#' Creates synthetic data for testing and demonstrating inequalitykit functions.
#' Three types are available: individual incomes, a two-period panel for growth
#' incidence analysis, and grouped incomes for decomposition.
#'
#' @param type Character. One of `"income"`, `"panel"`, or `"grouped"`.
#'
#' @return A data.frame.
#' \describe{
#'   \item{`"income"`}{1000 rows with columns `income` and `weight`.
#'     Drawn from a lognormal distribution (mean log 10.5, sd log 0.8),
#'     producing realistic income-like data centred around 40,000.}
#'   \item{`"panel"`}{1000 rows with columns `income_t0`, `income_t1`,
#'     `weight`. Two periods with heterogeneous growth (bottom grows
#'     slower than top, mimicking rising inequality).}
#'   \item{`"grouped"`}{1000 rows with columns `income`, `group`,
#'     `weight`. Three groups (A, B, C) with different mean incomes
#'     for between/within decomposition.}
#' }
#'
#' @export
#' @examples
#' d <- iq_sample_data("income")
#' head(d)
#'
#' panel <- iq_sample_data("panel")
#' head(panel)
#'
#' grouped <- iq_sample_data("grouped")
#' head(grouped)
iq_sample_data <- function(type = c("income", "panel", "grouped")) {
  type <- match.arg(type)
  set.seed(42L)

  switch(type,
    income  = .sample_income(),
    panel   = .sample_panel(),
    grouped = .sample_grouped()
  )
}

#' @noRd
.sample_income <- function() {
  n <- 1000L
  income <- round(rlnorm(n, meanlog = 10.5, sdlog = 0.8), 2)
  data.frame(
    income = income,
    weight = rep(1, n),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.sample_panel <- function() {
  n <- 1000L
  income_t0 <- round(rlnorm(n, meanlog = 10.5, sdlog = 0.8), 2)
  # Heterogeneous growth: bottom quintile grows ~2%, top quintile ~8%
  rank_pct <- rank(income_t0) / n
  growth <- 0.02 + 0.06 * rank_pct + rnorm(n, 0, 0.03)
  income_t1 <- round(income_t0 * (1 + growth), 2)
  data.frame(
    income_t0 = income_t0,
    income_t1 = income_t1,
    weight = rep(1, n),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.sample_grouped <- function() {
  n_a <- 400L
  n_b <- 350L
  n_c <- 250L
  income_a <- round(rlnorm(n_a, meanlog = 10.2, sdlog = 0.6), 2)
  income_b <- round(rlnorm(n_b, meanlog = 10.5, sdlog = 0.7), 2)
  income_c <- round(rlnorm(n_c, meanlog = 11.0, sdlog = 0.9), 2)
  data.frame(
    income = c(income_a, income_b, income_c),
    group = c(rep("A", n_a), rep("B", n_b), rep("C", n_c)),
    weight = rep(1, n_a + n_b + n_c),
    stringsAsFactors = FALSE
  )
}
