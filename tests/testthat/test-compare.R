test_that("iq_compare returns correct class", {
  d <- iq_sample_data("income")
  comp <- iq_compare(d$income)
  expect_s3_class(comp, "iq_comparison")
})

test_that("comparison table has all 12 measures", {
  d <- iq_sample_data("income")
  comp <- iq_compare(d$income)
  expect_equal(nrow(comp$table), 12)
  expect_true("Gini" %in% comp$table$measure)
  expect_true("S-Gini (delta=3)" %in% comp$table$measure)
  expect_true("Kolm (a=1)" %in% comp$table$measure)
  expect_true("Wolfson" %in% comp$table$measure)
})

test_that("all values are numeric", {
  d <- iq_sample_data("income")
  comp <- iq_compare(d$income)
  expect_type(comp$table$value, "double")
  expect_true(all(!is.na(comp$table$value)))
})

test_that("CIs cover every row when ci = TRUE", {
  d <- iq_sample_data("income")
  comp <- iq_compare(d$income, ci = TRUE, R = 100)
  expect_true("ci_lower" %in% names(comp$table))
  expect_true("ci_upper" %in% names(comp$table))
  expect_true(all(is.finite(comp$table$ci_lower)))
  expect_true(all(is.finite(comp$table$ci_upper)))
  expect_true(all(comp$table$ci_lower <= comp$table$ci_upper))
})

test_that("equal distribution gives zero inequality", {
  comp <- iq_compare(rep(100, 100))
  expect_equal(comp$table$value[comp$table$measure == "Gini"], 0, tolerance = 1e-10)
  expect_equal(comp$table$value[comp$table$measure == "Theil T (GE1)"], 0, tolerance = 1e-10)
  expect_equal(comp$table$value[comp$table$measure == "Kolm (a=1)"], 0, tolerance = 1e-6)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_compare(iq_sample_data("income")$income)))
  expect_no_error(print(iq_compare(iq_sample_data("income")$income, ci = TRUE, R = 50)))
})
