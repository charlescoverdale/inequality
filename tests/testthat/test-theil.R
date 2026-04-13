test_that("iq_theil returns correct class", {
  d <- iq_sample_data("income")
  t <- iq_theil(d$income)
  expect_s3_class(t, "iq_theil")
})

test_that("Theil T of equal incomes is 0", {
  t <- iq_theil(rep(100, 100), index = "T")
  expect_equal(t$value, 0, tolerance = 1e-10)
})

test_that("Theil L of equal incomes is 0", {
  t <- iq_theil(rep(100, 100), index = "L")
  expect_equal(t$value, 0, tolerance = 1e-10)
})

test_that("Theil is non-negative", {
  d <- iq_sample_data("income")
  t_T <- iq_theil(d$income, index = "T")
  t_L <- iq_theil(d$income, index = "L")
  expect_true(t_T$value >= 0)
  expect_true(t_L$value >= 0)
})

test_that("GE(2) is half the squared CV (population)", {
  x <- c(10, 20, 30, 40, 50)
  ge2 <- iq_theil(x, index = 2)
  # GE(2) uses population variance, not sample variance
  pop_var <- mean((x - mean(x))^2)
  cv_pop <- sqrt(pop_var) / mean(x)
  expect_equal(ge2$value, cv_pop^2 / 2, tolerance = 1e-6)
})

test_that("zero or negative incomes are rejected", {
  expect_error(iq_theil(c(0, 1, 2)), "strictly positive")
  expect_error(iq_theil(c(-1, 1, 2)), "strictly positive")
})

test_that("weights affect the result", {
  x <- c(10, 20, 30)
  t1 <- iq_theil(x)
  t2 <- iq_theil(x, weights = c(1, 1, 100))
  expect_false(t1$value == t2$value)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_theil(iq_sample_data("income")$income)))
})
