test_that("iq_poverty returns correct class", {
  d <- iq_sample_data("income")
  p <- iq_poverty(d$income, line = median(d$income))
  expect_s3_class(p, "iq_poverty")
})

test_that("headcount is proportion below line", {
  x <- c(5, 10, 15, 20, 25, 30)
  p <- iq_poverty(x, line = 16)
  expect_equal(p$headcount, 3 / 6, tolerance = 1e-10)
})

test_that("no poverty when line is below minimum", {
  p <- iq_poverty(c(10, 20, 30), line = 5)
  expect_equal(p$headcount, 0)
  expect_equal(p$gap, 0)
  expect_equal(p$severity, 0)
  expect_equal(p$sen, 0)
  expect_equal(p$watts, 0)
})

test_that("FGT(0) >= FGT(1) >= FGT(2) for typical data", {
  d <- iq_sample_data("income")
  p <- iq_poverty(d$income, line = quantile(d$income, 0.3))
  expect_true(p$headcount >= p$gap)
  expect_true(p$gap >= p$severity)
})

test_that("poverty line must be positive", {
  expect_error(iq_poverty(c(10, 20), line = 0), "positive")
  expect_error(iq_poverty(c(10, 20), line = -5), "positive")
})

test_that("Sen index is between 0 and headcount", {
  d <- iq_sample_data("income")
  p <- iq_poverty(d$income, line = median(d$income))
  expect_true(p$sen >= 0)
  expect_true(p$sen <= p$headcount + 0.01)
})

test_that("print method runs without error", {
  d <- iq_sample_data("income")
  expect_no_error(print(iq_poverty(d$income, line = median(d$income))))
})

test_that("bootstrap CIs work", {
  d <- iq_sample_data("income")
  p <- iq_poverty(d$income, line = median(d$income), ci = TRUE, R = 100)
  expect_false(is.null(p$ci))
  expect_true(p$ci$headcount$lower <= p$headcount)
  expect_true(p$ci$headcount$upper >= p$headcount)
})
