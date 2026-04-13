test_that("iq_lorenz returns correct class", {
  d <- iq_sample_data("income")
  lc <- iq_lorenz(d$income)
  expect_s3_class(lc, "iq_lorenz")
})

test_that("Lorenz curve starts at (0,0) and ends at (1,1)", {
  d <- iq_sample_data("income")
  lc <- iq_lorenz(d$income)
  expect_equal(lc$curve$cum_pop[1], 0)
  expect_equal(lc$curve$cum_income[1], 0)
  expect_equal(lc$curve$cum_pop[nrow(lc$curve)], 1, tolerance = 1e-10)
  expect_equal(lc$curve$cum_income[nrow(lc$curve)], 1, tolerance = 1e-10)
})

test_that("Lorenz curve is non-decreasing", {
  d <- iq_sample_data("income")
  lc <- iq_lorenz(d$income)
  diffs <- diff(lc$curve$cum_income)
  expect_true(all(diffs >= -1e-10))
})

test_that("equal distribution has Lorenz on diagonal", {
  lc <- iq_lorenz(rep(100, 10))
  expect_equal(lc$curve$cum_pop, lc$curve$cum_income, tolerance = 1e-10)
  expect_equal(lc$gini, 0, tolerance = 1e-10)
})

test_that("Gini from Lorenz matches iq_gini", {
  d <- iq_sample_data("income")
  lc <- iq_lorenz(d$income)
  g <- iq_gini(d$income)
  expect_equal(lc$gini, g$gini, tolerance = 1e-10)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_lorenz(iq_sample_data("income")$income)))
})

test_that("plot method runs without error", {
  lc <- iq_lorenz(iq_sample_data("income")$income)
  expect_no_error(plot(lc))
})
