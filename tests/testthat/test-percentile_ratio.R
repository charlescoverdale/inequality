test_that("iq_percentile_ratio returns correct class", {
  d <- iq_sample_data("income")
  pr <- iq_percentile_ratio(d$income)
  expect_s3_class(pr, "iq_percentile_ratio")
})

test_that("P90/P10 is greater than 1 for unequal data", {
  d <- iq_sample_data("income")
  pr <- iq_percentile_ratio(d$income)
  expect_true(pr$ratio > 1)
})

test_that("custom percentiles work", {
  d <- iq_sample_data("income")
  pr <- iq_percentile_ratio(d$income, upper = 80, lower = 20)
  expect_equal(pr$upper, 80)
  expect_equal(pr$lower, 20)
})

test_that("upper must exceed lower", {
  expect_error(iq_percentile_ratio(1:100, upper = 10, lower = 90))
})

test_that("equal distribution gives ratio of 1", {
  pr <- iq_percentile_ratio(rep(50, 100))
  expect_equal(pr$ratio, 1, tolerance = 1e-10)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_percentile_ratio(iq_sample_data("income")$income)))
})

test_that("bootstrap CI works", {
  d <- iq_sample_data("income")
  pr <- iq_percentile_ratio(d$income, ci = TRUE, R = 100)
  expect_false(is.null(pr$ci_lower))
  expect_false(is.null(pr$ci_upper))
})
