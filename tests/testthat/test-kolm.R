test_that("iq_kolm returns correct class", {
  d <- iq_sample_data("income")
  k <- iq_kolm(d$income)
  expect_s3_class(k, "iq_kolm")
})

test_that("Kolm of equal incomes is 0", {
  k <- iq_kolm(rep(100, 100))
  expect_equal(k$value, 0, tolerance = 1e-10)
})

test_that("Kolm is non-negative", {
  d <- iq_sample_data("income")
  k <- iq_kolm(d$income)
  expect_true(k$value >= 0)
})

test_that("higher alpha increases the index for unequal data", {
  d <- iq_sample_data("income")
  k1 <- iq_kolm(d$income, alpha = 0.5)
  k2 <- iq_kolm(d$income, alpha = 2)
  expect_true(k2$value > k1$value)
})

test_that("Kolm is translation invariant", {
  x <- c(10, 20, 30, 40, 50)
  k1 <- iq_kolm(x, alpha = 1)
  k2 <- iq_kolm(x + 1000, alpha = 1)
  expect_equal(k1$value, k2$value, tolerance = 1e-4)
})

test_that("invalid alpha is rejected", {
  expect_error(iq_kolm(c(10, 20), alpha = 0), "positive")
  expect_error(iq_kolm(c(10, 20), alpha = -1), "positive")
})

test_that("print method runs without error", {
  expect_no_error(print(iq_kolm(iq_sample_data("income")$income)))
})
