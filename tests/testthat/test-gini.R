test_that("iq_gini returns correct class", {
  d <- iq_sample_data("income")
  g <- iq_gini(d$income)
  expect_s3_class(g, "iq_gini")
})

test_that("Gini of equal incomes is 0", {
  g <- iq_gini(rep(100, 100))
  expect_equal(g$gini, 0)
})

test_that("Gini of maximum inequality is correct", {
  # c(0, 0, 0, 0, 10): Gini = 1 - 1/n = 0.8
  g <- iq_gini(c(0, 0, 0, 0, 10))
  expect_equal(g$gini, 0.8, tolerance = 1e-10)
})

test_that("Gini is between 0 and 1", {
  d <- iq_sample_data("income")
  g <- iq_gini(d$income)
  expect_true(g$gini >= 0 && g$gini <= 1)
})

test_that("bootstrap CI works", {
  d <- iq_sample_data("income")
  g <- iq_gini(d$income, ci = TRUE, R = 200)
  expect_false(is.null(g$ci_lower))
  expect_false(is.null(g$ci_upper))
  expect_true(g$ci_lower < g$gini)
  expect_true(g$ci_upper > g$gini)
})

test_that("weights affect the result", {
  x <- c(10, 20, 30)
  g1 <- iq_gini(x)
  g2 <- iq_gini(x, weights = c(1, 1, 100))
  expect_false(g1$gini == g2$gini)
})

test_that("na.rm works", {
  expect_error(iq_gini(c(1, 2, NA, 4)))
  g <- iq_gini(c(1, 2, NA, 4), na.rm = TRUE)
  expect_s3_class(g, "iq_gini")
})

test_that("print method runs without error", {
  g <- iq_gini(iq_sample_data("income")$income, ci = TRUE, R = 100)
  expect_no_error(print(g))
})

test_that("negative values are rejected", {
  expect_error(iq_gini(c(-1, 2, 3)), "non-negative")
})
