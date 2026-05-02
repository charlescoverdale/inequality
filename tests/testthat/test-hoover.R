test_that("iq_hoover returns correct class", {
  d <- iq_sample_data("income")
  h <- iq_hoover(d$income)
  expect_s3_class(h, "iq_hoover")
})

test_that("Hoover of equal incomes is 0", {
  h <- iq_hoover(rep(100, 50))
  expect_equal(h$value, 0, tolerance = 1e-10)
})

test_that("Hoover is between 0 and 1", {
  d <- iq_sample_data("income")
  h <- iq_hoover(d$income)
  expect_true(h$value >= 0 && h$value <= 1)
})

test_that("known calculation", {
  # x = c(1, 2, 3), mean = 2
  # H = 0.5 * (|1/2 - 1| + |2/2 - 1| + |3/2 - 1|) / 3 * 3
  # = 0.5 * (1/3 * 0.5 + 1/3 * 0 + 1/3 * 0.5) = 0.5 * 1/3 = 1/6
  h <- iq_hoover(c(1, 2, 3))
  expect_equal(h$value, 1 / 6, tolerance = 1e-10)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_hoover(iq_sample_data("income")$income)))
})

test_that("bootstrap CI works", {
  d <- iq_sample_data("income")
  h <- iq_hoover(d$income, ci = TRUE, R = 100)
  expect_false(is.null(h$ci_lower))
  expect_false(is.null(h$ci_upper))
})
