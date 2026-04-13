test_that("iq_atkinson returns correct class", {
  d <- iq_sample_data("income")
  a <- iq_atkinson(d$income, epsilon = 0.5)
  expect_s3_class(a, "iq_atkinson")
})

test_that("Atkinson of equal incomes is 0", {
  a <- iq_atkinson(rep(100, 100), epsilon = 0.5)
  expect_equal(a$value, 0, tolerance = 1e-10)
})

test_that("Atkinson is between 0 and 1", {
  d <- iq_sample_data("income")
  a <- iq_atkinson(d$income, epsilon = 0.5)
  expect_true(a$value >= 0 && a$value <= 1)
})

test_that("higher epsilon increases the index", {
  d <- iq_sample_data("income")
  a1 <- iq_atkinson(d$income, epsilon = 0.5)
  a2 <- iq_atkinson(d$income, epsilon = 2.0)
  expect_true(a2$value > a1$value)
})

test_that("epsilon = 1 uses log formula", {
  x <- c(10, 20, 30, 40, 50)
  a <- iq_atkinson(x, epsilon = 1)
  ede <- exp(mean(log(x)))
  expected <- 1 - ede / mean(x)
  expect_equal(a$value, expected, tolerance = 1e-10)
})

test_that("invalid epsilon is rejected", {
  expect_error(iq_atkinson(c(10, 20), epsilon = 0), "positive")
  expect_error(iq_atkinson(c(10, 20), epsilon = -1), "positive")
})

test_that("EDE is less than mean for unequal distribution", {
  d <- iq_sample_data("income")
  a <- iq_atkinson(d$income, epsilon = 1)
  expect_true(a$ede < a$mean_income)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_atkinson(iq_sample_data("income")$income)))
})
