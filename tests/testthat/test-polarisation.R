test_that("iq_polarisation returns correct class", {
  d <- iq_sample_data("income")
  p <- iq_polarisation(d$income)
  expect_s3_class(p, "iq_polarisation")
})

test_that("Wolfson index is non-negative", {
  d <- iq_sample_data("income")
  p <- iq_polarisation(d$income)
  expect_true(p$wolfson >= 0)
})

test_that("equal distribution has zero polarisation", {
  p <- iq_polarisation(rep(100, 100))
  expect_equal(p$wolfson, 0, tolerance = 1e-10)
})

test_that("Gini is computed correctly", {
  d <- iq_sample_data("income")
  p <- iq_polarisation(d$income)
  g <- iq_gini(d$income)
  expect_equal(p$gini, g$gini, tolerance = 1e-10)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_polarisation(iq_sample_data("income")$income)))
})
