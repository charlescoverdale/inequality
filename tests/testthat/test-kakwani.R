test_that("iq_kakwani returns correct class", {
  set.seed(1)
  pre <- iq_sample_data("income")$income
  tax <- pre * 0.2
  k <- iq_kakwani(pre, tax)
  expect_s3_class(k, "iq_kakwani")
})

test_that("proportional tax gives Kakwani near zero", {
  set.seed(1)
  pre <- iq_sample_data("income")$income
  tax <- pre * 0.2  # flat 20% rate
  k <- iq_kakwani(pre, tax)
  expect_equal(k$kakwani, 0, tolerance = 0.01)
})

test_that("progressive tax gives positive Kakwani", {
  set.seed(1)
  pre <- iq_sample_data("income")$income
  tax <- pre * (0.10 + 0.15 * (pre / max(pre)))
  k <- iq_kakwani(pre, tax)
  expect_true(k$kakwani > 0)
})

test_that("Reynolds-Smolensky is positive for progressive tax", {
  set.seed(1)
  pre <- iq_sample_data("income")$income
  tax <- pre * (0.10 + 0.15 * (pre / max(pre)))
  k <- iq_kakwani(pre, tax)
  expect_true(k$reynolds_smolensky > 0)
})

test_that("pre_tax and tax must have same length", {
  expect_error(iq_kakwani(1:10, 1:5), "same length")
})

test_that("print method runs without error", {
  set.seed(1)
  pre <- iq_sample_data("income")$income
  tax <- pre * 0.2
  expect_no_error(print(iq_kakwani(pre, tax)))
})
