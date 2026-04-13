test_that("iq_sgini returns correct class", {
  d <- iq_sample_data("income")
  sg <- iq_sgini(d$income)
  expect_s3_class(sg, "iq_sgini")
})

test_that("S-Gini at delta=2 equals standard Gini", {
  d <- iq_sample_data("income")
  sg <- iq_sgini(d$income, delta = 2)
  g <- iq_gini(d$income)
  expect_equal(sg$value, g$gini, tolerance = 1e-6)
})

test_that("S-Gini of equal incomes is 0", {
  sg <- iq_sgini(rep(100, 100), delta = 2)
  expect_equal(sg$value, 0, tolerance = 1e-10)
})

test_that("higher delta increases index for unequal data", {
  d <- iq_sample_data("income")
  sg2 <- iq_sgini(d$income, delta = 2)
  sg4 <- iq_sgini(d$income, delta = 4)
  expect_true(sg4$value > sg2$value)
})

test_that("delta must be greater than 1", {
  expect_error(iq_sgini(c(10, 20), delta = 1), "greater than 1")
  expect_error(iq_sgini(c(10, 20), delta = 0.5), "greater than 1")
})

test_that("print method runs without error", {
  expect_no_error(print(iq_sgini(iq_sample_data("income")$income)))
})
