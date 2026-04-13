test_that("iq_decompose returns correct class", {
  d <- iq_sample_data("grouped")
  dc <- iq_decompose(d$income, d$group)
  expect_s3_class(dc, "iq_decomposition")
})

test_that("between + within = total (additivity)", {
  d <- iq_sample_data("grouped")
  dc <- iq_decompose(d$income, d$group, index = "T")
  expect_equal(dc$between + dc$within, dc$total, tolerance = 1e-10)

  dc_l <- iq_decompose(d$income, d$group, index = "L")
  expect_equal(dc_l$between + dc_l$within, dc_l$total, tolerance = 1e-10)
})

test_that("within is zero when all groups are equal internally", {
  x <- c(10, 10, 10, 20, 20, 20)
  g <- c("A", "A", "A", "B", "B", "B")
  dc <- iq_decompose(x, g, index = "T")
  expect_equal(dc$within, 0, tolerance = 1e-10)
  expect_equal(dc$between, dc$total, tolerance = 1e-10)
})

test_that("between is zero when all groups have same mean", {
  set.seed(1)
  x <- c(rnorm(100, 50, 5), rnorm(100, 50, 10))
  g <- rep(c("A", "B"), each = 100)
  # Adjust to force exact same mean
  x[1:100] <- x[1:100] - mean(x[1:100]) + 50
  x[101:200] <- x[101:200] - mean(x[101:200]) + 50
  x <- abs(x) + 1  # ensure positive
  dc <- iq_decompose(x, g, index = "T")
  expect_true(dc$between < 0.001)
})

test_that("group detail has correct columns", {
  d <- iq_sample_data("grouped")
  dc <- iq_decompose(d$income, d$group)
  expect_named(dc$groups, c("group", "n", "mean_income", "pop_share",
                             "income_share", "within_ge"))
})

test_that("group and x must have same length", {
  expect_error(iq_decompose(1:10, c("A", "B")), "same length")
})

test_that("print method runs without error", {
  d <- iq_sample_data("grouped")
  expect_no_error(print(iq_decompose(d$income, d$group)))
})
