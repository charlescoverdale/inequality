# Property-based axiom tests.
#
# These tests verify that each inequality measure satisfies the axiomatic
# properties claimed for it in the documentation: scale invariance for
# relative measures, translation invariance for the (absolute) Kolm index,
# the Pigou-Dalton transfer principle, and anonymity. Failures here indicate
# that the formula no longer matches the literature.

set.seed(7)
.x_lognormal <- rlnorm(200, 10, 0.7)

.relative_indices <- list(
  Gini  = function(x) iq_gini(x)$gini,
  ThT   = function(x) iq_theil(x, index = "T")$value,
  ThL   = function(x) iq_theil(x, index = "L")$value,
  Atk05 = function(x) iq_atkinson(x, epsilon = 0.5)$value,
  Atk10 = function(x) iq_atkinson(x, epsilon = 1.0)$value,
  SGn3  = function(x) iq_sgini(x, delta = 3)$value,
  Plm   = function(x) iq_palma(x)$palma,
  Hvr   = function(x) iq_hoover(x)$value,
  P9010 = function(x) iq_percentile_ratio(x)$ratio
)

test_that("relative indices are scale invariant", {
  for (nm in names(.relative_indices)) {
    f <- .relative_indices[[nm]]
    expect_equal(f(1000 * .x_lognormal), f(.x_lognormal),
                 tolerance = 1e-8,
                 info = paste("scale invariance failed for", nm))
  }
})

test_that("Kolm index is translation invariant", {
  k1 <- iq_kolm(.x_lognormal)$value
  k2 <- iq_kolm(.x_lognormal + 1e6)$value
  expect_equal(k1, k2, tolerance = 1e-4)
})

test_that("Pigou-Dalton transfer reduces every relative inequality measure", {
  # Move 1% of total income from the richest to the poorest.
  x <- .x_lognormal
  amt <- 0.01 * sum(x)
  y <- x
  y[which.max(y)] <- y[which.max(y)] - amt
  y[which.min(y)] <- y[which.min(y)] + amt
  for (nm in names(.relative_indices)) {
    f <- .relative_indices[[nm]]
    delta <- f(y) - f(x)
    expect_lt(delta, 0,
              label = paste("transfer principle failed for", nm,
                            "(delta =", signif(delta, 3), ")"))
  }
})

test_that("indices are anonymous (permutation invariant)", {
  set.seed(11)
  y_perm <- sample(.x_lognormal)
  for (nm in names(.relative_indices)) {
    f <- .relative_indices[[nm]]
    expect_equal(f(.x_lognormal), f(y_perm),
                 tolerance = 1e-8,
                 info = paste("anonymity failed for", nm))
  }
})

test_that("Atkinson is non-decreasing in epsilon", {
  eps_grid <- c(0.1, 0.5, 1, 1.5, 2, 3, 5, 10)
  vals <- vapply(eps_grid,
                 function(e) iq_atkinson(.x_lognormal, epsilon = e)$value,
                 numeric(1))
  expect_true(all(diff(vals) >= -1e-12))
})

test_that("S-Gini is non-decreasing in delta", {
  delta_grid <- c(1.1, 1.5, 2, 3, 4, 6, 10)
  vals <- vapply(delta_grid,
                 function(d) iq_sgini(.x_lognormal, delta = d)$value,
                 numeric(1))
  expect_true(all(diff(vals) >= -1e-12))
})

test_that("Kolm is non-decreasing in alpha", {
  alpha_grid <- c(0.1, 0.5, 1, 2, 5)
  # Use a smaller, less skewed sample because the Kolm exponent overflows
  # at high alpha on heavy-tailed data.
  set.seed(3)
  x <- rlnorm(200, 0, 0.5)
  vals <- vapply(alpha_grid,
                 function(a) iq_kolm(x, alpha = a)$value,
                 numeric(1))
  expect_true(all(diff(vals) >= -1e-10))
})

test_that("Lorenz dominance: equal beats half-half on Gini", {
  g_equal <- iq_gini(rep(100, 100))$gini
  g_half  <- iq_gini(c(rep(50, 50), rep(150, 50)))$gini
  expect_lt(g_equal, g_half + 1e-12)
})

test_that("S-Gini at delta=2 equals the standard Gini", {
  d <- iq_sample_data("income")$income
  expect_equal(iq_sgini(d, delta = 2)$value, iq_gini(d)$gini,
               tolerance = 1e-10)
})

test_that("decomposition exactness: between + within = total for GE family", {
  d <- iq_sample_data("grouped")
  for (idx in list("T", "L", 0.5, 2)) {
    dec <- iq_decompose(d$income, d$group,
                        index = if (is.character(idx)) idx else as.numeric(idx))
    expect_equal(dec$total, dec$between + dec$within,
                 tolerance = 1e-10,
                 info = paste("decomposition broken for index =", idx))
  }
})

test_that("bootstrap CI on Gini achieves nominal 95% coverage", {
  skip_on_cran()
  set.seed(73)
  truth <- iq_gini(rlnorm(50000, 10, 0.7))$gini  # population proxy
  B <- 60
  hits <- 0L
  for (b in seq_len(B)) {
    xb <- rlnorm(200, 10, 0.7)
    g <- iq_gini(xb, ci = TRUE, R = 200)
    if (g$ci_lower <= truth && truth <= g$ci_upper) hits <- hits + 1L
  }
  # 95% nominal at B = 60 has Wilson 95% CI of roughly 36% to 100%; we
  # check for "within Monte-Carlo error of nominal" at +/- 18 percentage
  # points of 95%.
  cov <- hits / B
  expect_gt(cov, 0.77)
  expect_lt(cov, 1.001)
})

test_that("Erreygers correction lies in [-1, 1] for binary outcomes", {
  set.seed(2)
  income <- sort(rlnorm(500, 10, 0.6))
  sick <- as.numeric(income < median(income))
  ci_err <- iq_concentration(sick, rank = income, correction = "erreygers")$value
  expect_lte(abs(ci_err), 1 + 1e-10)
})

test_that("Wagstaff correction agrees with Erreygers up to a known scaling", {
  # For a binary outcome bounded in [0, 1] with mean mu, both corrections
  # divide the standard CI by a function of mu; their ratio is fixed.
  set.seed(2)
  income <- sort(rlnorm(500, 10, 0.6))
  sick <- as.numeric(income < median(income))
  c_std <- iq_concentration(sick, rank = income)$value
  c_err <- iq_concentration(sick, rank = income, correction = "erreygers")$value
  c_wag <- iq_concentration(sick, rank = income, correction = "wagstaff")$value
  mu <- mean(sick)
  expect_equal(c_err, 4 * mu * c_std, tolerance = 1e-10)
  expect_equal(c_wag, c_std / (1 - mu), tolerance = 1e-10)
})

test_that("Raffinetti normalised Gini is bounded in [-1, 1] under negatives", {
  # The normalised Gini of Raffinetti et al. (2017) replaces the divisor
  # |mu| with mean(|x|), so the index stays bounded in [-1, 1] regardless
  # of sign composition.
  set.seed(4)
  for (rep in seq_len(20)) {
    n <- sample(20:200, 1)
    x <- rnorm(n, mean = 0, sd = sample(c(1, 100, 1e4), 1))
    g <- iq_gini(x, negatives = "keep", normalised = TRUE)$gini
    expect_true(is.na(g) || abs(g) <= 1 + 1e-10,
                info = paste("normalised Gini out of [-1,1]:", g))
  }
})

test_that("standard Gini returns NA when population mean is non-positive", {
  # Balanced symmetric distribution has mu = 0; the standard formula has
  # no inequality interpretation and should return NA, not 0.
  expect_warning(g <- iq_gini(c(-100, -50, 50, 100), negatives = "keep"))
  expect_true(is.na(g$gini))
  # All-debtor sample (mu < 0) is also undefined for the standard form.
  expect_warning(g2 <- iq_gini(c(-100, -50, -10), negatives = "keep"))
  expect_true(is.na(g2$gini))
})

test_that("iq_compare with negatives = 'keep' returns NA for log-based rows", {
  wealth <- c(-5000, 0, 5000, 20000, 80000, 250000, 1e6)
  comp <- iq_compare(wealth, negatives = "keep")
  log_rows <- comp$table[comp$table$measure %in%
                         c("Theil T (GE1)", "Theil L (GE0)",
                           "Atkinson (e=0.5)", "Atkinson (e=1.0)"), ]
  expect_true(all(is.na(log_rows$value)))
  # Gini, Kolm, Hoover, P-ratios should still compute on this sample
  expect_false(is.na(comp$table$value[comp$table$measure == "Gini"]))
  expect_false(is.na(comp$table$value[comp$table$measure == "Kolm (a=1)"]))
})

test_that("Watts index drops x = 0 with a warning", {
  # One household at x = 0, others poor at positive incomes.
  expect_warning(p <- iq_poverty(c(0, 5, 10, 15, 100), line = 20),
                 "Watts")
  # Watts is computed only on the three positive poor (5, 10, 15)
  expect_true(is.finite(p$watts))
  expect_gt(p$watts, 0)
})
