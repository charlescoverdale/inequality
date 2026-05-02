test_that("iq_concentration returns correct class", {
  set.seed(1)
  x <- rlnorm(100, 10, 0.5)
  r <- rlnorm(100, 10, 0.8)
  c <- iq_concentration(x, rank = r)
  expect_s3_class(c, "iq_concentration")
})

test_that("concentration index is between -1 and 1", {
  set.seed(1)
  x <- rlnorm(200, 10, 0.5)
  r <- rlnorm(200, 10, 0.8)
  c <- iq_concentration(x, rank = r)
  expect_true(c$value >= -1 && c$value <= 1)
})

test_that("positively correlated outcome gives positive CI", {
  set.seed(1)
  income <- 1:100
  health_spend <- income * 2 + rnorm(100, 0, 5)
  c <- iq_concentration(health_spend, rank = income)
  expect_true(c$value > 0)
})

test_that("rank and x must have same length", {
  expect_error(iq_concentration(1:10, rank = 1:5), "same length")
})

test_that("equal outcome gives CI near zero", {
  c <- iq_concentration(rep(100, 50), rank = 1:50)
  expect_equal(c$value, 0, tolerance = 1e-10)
})

test_that("print method runs without error", {
  set.seed(1)
  x <- rlnorm(100, 10, 0.5)
  expect_no_error(print(iq_concentration(x, rank = x)))
})

test_that("bootstrap CI works", {
  set.seed(1)
  x <- rlnorm(200, 10, 0.5)
  r <- rlnorm(200, 10, 0.8)
  ci_obj <- iq_concentration(x, rank = r, ci = TRUE, R = 100)
  expect_false(is.null(ci_obj$ci_lower))
  expect_false(is.null(ci_obj$ci_upper))
})
