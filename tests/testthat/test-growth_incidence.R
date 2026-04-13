test_that("iq_growth_incidence returns correct class", {
  d <- iq_sample_data("panel")
  gic <- iq_growth_incidence(d$income_t0, d$income_t1)
  expect_s3_class(gic, "iq_growth_incidence")
})

test_that("GIC has correct number of quantiles", {
  d <- iq_sample_data("panel")
  gic <- iq_growth_incidence(d$income_t0, d$income_t1, n_quantiles = 10)
  expect_equal(nrow(gic$gic), 10)
})

test_that("x_t0 and x_t1 must have same length", {
  expect_error(iq_growth_incidence(1:10, 1:5), "same length")
})

test_that("positive growth when t1 > t0 everywhere", {
  x0 <- rep(100, 50)
  x1 <- rep(110, 50)
  gic <- iq_growth_incidence(x0, x1)
  expect_true(all(gic$gic$growth > 0))
  expect_equal(gic$mean_growth, 0.10, tolerance = 0.01)
})

test_that("print method runs without error", {
  d <- iq_sample_data("panel")
  expect_no_error(print(iq_growth_incidence(d$income_t0, d$income_t1)))
})

test_that("plot method runs without error", {
  d <- iq_sample_data("panel")
  gic <- iq_growth_incidence(d$income_t0, d$income_t1)
  expect_no_error(plot(gic))
})
