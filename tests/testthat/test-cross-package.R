# Cross-package numerical checks against the legacy `ineq` package.
#
# Skipped on CRAN and when `ineq` is not installed locally. The intent is to
# protect against silent regressions in the closed-form formulas. `ineq` has
# been frozen since 2014 and its results are widely cited.

test_that("inequality matches ineq on a fixed lognormal sample", {
  skip_on_cran()
  skip_if_not_installed("ineq")

  set.seed(1)
  x <- rlnorm(500, 10, 0.8)

  expect_equal(iq_gini(x)$gini, ineq::Gini(x),
               tolerance = 1e-10, info = "Gini")

  # Convention difference: ineq::Theil(x, parameter = 0) is GE(1) (Theil T).
  expect_equal(iq_theil(x, index = "T")$value,
               ineq::Theil(x, parameter = 0),
               tolerance = 1e-10, info = "Theil T")
  expect_equal(iq_theil(x, index = "L")$value,
               ineq::Theil(x, parameter = 1),
               tolerance = 1e-10, info = "Theil L")

  expect_equal(iq_atkinson(x, epsilon = 0.5)$value,
               ineq::Atkinson(x, parameter = 0.5),
               tolerance = 1e-10, info = "Atkinson e=0.5")
  expect_equal(iq_atkinson(x, epsilon = 1.0)$value,
               ineq::Atkinson(x, parameter = 1.0),
               tolerance = 1e-10, info = "Atkinson e=1")
})

test_that("inequality matches ineq with zeros included", {
  skip_on_cran()
  skip_if_not_installed("ineq")

  set.seed(11)
  x <- c(rep(0, 50), rlnorm(450, 10, 0.8))

  expect_equal(iq_gini(x)$gini, ineq::Gini(x),
               tolerance = 1e-10)
})
