test_that("iq_compare returns correct class", {
  d <- iq_sample_data("income")
  comp <- iq_compare(d$income)
  expect_s3_class(comp, "iq_comparison")
})

test_that("comparison table has 9 rows", {
  d <- iq_sample_data("income")
  comp <- iq_compare(d$income)
  expect_equal(nrow(comp$table), 9)
})

test_that("all values are numeric", {
  d <- iq_sample_data("income")
  comp <- iq_compare(d$income)
  expect_type(comp$table$value, "double")
  expect_true(all(!is.na(comp$table$value)))
})

test_that("CI is included when requested", {
  d <- iq_sample_data("income")
  comp <- iq_compare(d$income, ci = TRUE, R = 100)
  expect_false(is.null(comp$gini_ci))
  expect_true(comp$gini_ci$lower < comp$gini_ci$upper)
})

test_that("equal distribution gives zero inequality", {
  comp <- iq_compare(rep(100, 100))
  expect_equal(comp$table$value[comp$table$measure == "Gini"], 0, tolerance = 1e-10)
  expect_equal(comp$table$value[comp$table$measure == "Theil T (GE1)"], 0, tolerance = 1e-10)
})

test_that("print method runs without error", {
  expect_no_error(print(iq_compare(iq_sample_data("income")$income)))
})
