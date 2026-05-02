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

test_that("bootstrap CIs work", {
  set.seed(1)
  pre <- iq_sample_data("income")$income
  tax <- pre * (0.10 + 0.15 * (pre / max(pre)))
  k <- iq_kakwani(pre, tax, ci = TRUE, R = 100)
  expect_false(is.null(k$kakwani_ci))
  expect_false(is.null(k$rs_ci))
  expect_true(k$kakwani_ci$lower <= k$kakwani)
  expect_true(k$kakwani_ci$upper >= k$kakwani)
})

test_that("post-tax Gini does not abs() negative net incomes", {
  # Construct a small example where post-tax income is negative for one
  # household. The previous abs(post) bug gave a smaller post-tax Gini
  # than the honest formula.
  pre <- c(100, 200, 300, 400, 500)
  tax <- c(0, 0, 0, 0, 600)  # last household pushed to -100
  k <- iq_kakwani(pre, tax)
  honest_post <- pre - tax
  # Replicate the internal weighted Gini directly. With negatives present
  # the result can exceed 1; the point is that we are not flipping signs.
  w <- rep(1 / length(pre), length(pre))
  expected <- inequality:::.gini_weighted(honest_post, w)
  expect_equal(k$gini_post, expected, tolerance = 1e-10)
})
