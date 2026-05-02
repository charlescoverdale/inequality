test_that("iq_shares returns correct class", {
  d <- iq_sample_data("income")
  s <- iq_shares(d$income)
  expect_s3_class(s, "iq_shares")
})

test_that("default breaks produce 4 segments", {
  d <- iq_sample_data("income")
  s <- iq_shares(d$income)
  expect_equal(nrow(s$shares), 4)
})

test_that("shares sum to approximately 1", {
  d <- iq_sample_data("income")
  s <- iq_shares(d$income)
  expect_equal(sum(s$shares$income_share), 1, tolerance = 0.05)
})

test_that("equal distribution has proportional shares", {
  s <- iq_shares(rep(100, 100))
  # Bottom 50% should get ~50% of income in an equal distribution
  expect_equal(s$shares$income_share[1], 0.50, tolerance = 0.05)
})

test_that("custom quintile breaks work", {
  d <- iq_sample_data("income")
  s <- iq_shares(d$income, breaks = c(0.20, 0.40, 0.60, 0.80, 1.00))
  expect_equal(nrow(s$shares), 5)
})

test_that("top segments capture disproportionate share for skewed data", {
  d <- iq_sample_data("income")
  s <- iq_shares(d$income)
  # Top 1% should hold more than 1% of income
  top1 <- s$shares[s$shares$segment == "Top 1%", ]
  expect_true(top1$income_share > top1$pop_share)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_shares(iq_sample_data("income")$income)))
})

test_that("bootstrap CIs are added to each segment", {
  d <- iq_sample_data("income")
  s <- iq_shares(d$income, ci = TRUE, R = 100)
  expect_true("ci_lower" %in% names(s$shares))
  expect_true("ci_upper" %in% names(s$shares))
  expect_true(all(s$shares$ci_lower <= s$shares$ci_upper))
})

test_that("negatives = 'keep' permits negative values with warning", {
  wealth <- c(-5000, -1000, 0, 5000, 20000, 80000, 250000, 1e6)
  expect_warning(s <- iq_shares(wealth, negatives = "keep"), "outside")
  expect_s3_class(s, "iq_shares")
  expect_true(s$has_negatives)
})

test_that("negatives = 'error' rejects negatives", {
  expect_error(iq_shares(c(-1, 2, 3, 4)), "non-negative")
})
