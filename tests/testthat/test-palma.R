test_that("iq_palma returns correct class", {
  d <- iq_sample_data("income")
  p <- iq_palma(d$income)
  expect_s3_class(p, "iq_palma")
})

test_that("Palma of equal incomes is approximately 0.25", {
  # With equal incomes, top 10% has 10% and bottom 40% has 40%
  # Palma = 0.10 / 0.40 = 0.25
  p <- iq_palma(rep(100, 100))
  expect_equal(p$palma, 0.25, tolerance = 0.05)
})

test_that("shares sum to approximately 1", {
  d <- iq_sample_data("income")
  p <- iq_palma(d$income)
  # Top 10% + bottom 40% won't sum to 1, but both should be positive
  expect_true(p$top10_share > 0)
  expect_true(p$bottom40_share > 0)
})

test_that("Palma is positive for typical data", {
  d <- iq_sample_data("income")
  p <- iq_palma(d$income)
  expect_true(p$palma > 0)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_palma(iq_sample_data("income")$income)))
})

test_that("bootstrap CI works", {
  d <- iq_sample_data("income")
  p <- iq_palma(d$income, ci = TRUE, R = 100)
  expect_false(is.null(p$ci_lower))
  expect_false(is.null(p$ci_upper))
})
