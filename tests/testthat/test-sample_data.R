test_that("iq_sample_data('income') returns correct structure", {
  d <- iq_sample_data("income")
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 1000)
  expect_named(d, c("income", "weight"))
  expect_type(d$income, "double")
  expect_true(all(d$income > 0))
})

test_that("iq_sample_data('panel') returns correct structure", {
  d <- iq_sample_data("panel")
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 1000)
  expect_named(d, c("income_t0", "income_t1", "weight"))
  expect_true(all(d$income_t0 > 0))
  expect_true(all(d$income_t1 > 0))
})

test_that("iq_sample_data('grouped') returns correct structure", {
  d <- iq_sample_data("grouped")
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 1000)
  expect_named(d, c("income", "group", "weight"))
  expect_true(all(d$group %in% c("A", "B", "C")))
})

test_that("iq_sample_data is reproducible", {
  d1 <- iq_sample_data("income")
  d2 <- iq_sample_data("income")
  expect_identical(d1, d2)
})

test_that("iq_sample_data does not affect external RNG state", {
  set.seed(123)
  x_before <- runif(1)
  set.seed(123)
  iq_sample_data("income")
  x_after <- runif(1)
  expect_equal(x_before, x_after)
})
