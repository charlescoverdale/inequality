# Theil index and generalised entropy measures

Computes the Theil T index (GE(1)), Theil L / mean log deviation
(GE(0)), or a generalised entropy index GE(alpha) for any non-negative
alpha.

## Usage

``` r
iq_theil(
  x,
  weights = NULL,
  index = "T",
  na.rm = FALSE,
  ci = FALSE,
  R = 1000L,
  level = 0.95
)
```

## Arguments

- x:

  Numeric vector of incomes (strictly positive).

- weights:

  Optional numeric vector of survey weights.

- index:

  Character or numeric. `"T"` for Theil T (GE(1)), `"L"` for mean log
  deviation (GE(0)), or a numeric value for GE(alpha). Default `"T"`.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap confidence intervals? Default `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

## Value

An S3 object of class `"iq_theil"` with elements:

- value:

  Numeric. The index value.

- alpha:

  Numeric. The alpha parameter used.

- index_name:

  Character. Human-readable name of the index.

- n:

  Integer. Number of observations.

- se:

  Numeric or `NULL`. Bootstrap standard error.

- ci_lower:

  Numeric or `NULL`. Lower bound of the CI.

- ci_upper:

  Numeric or `NULL`. Upper bound of the CI.

- level:

  Numeric or `NULL`. Confidence level.

## Details

Generalised entropy indices are the only class of inequality measures
that are both decomposable by population subgroups and satisfy the
transfer principle. Higher values indicate more inequality.

Theil T (GE(1)) and Theil L (GE(0)) involve `log(x)` and so require
strictly positive values. GE(alpha) for `alpha > 1` is well-defined for
non-negative `x` but is highly sensitive to small or zero values. For
wealth or income net of taxes/transfers (which can be zero or negative)
use the Gini, S-Gini, or Kolm index instead.

Note on cross-validation against
[ineq](https://CRAN.R-project.org/package=ineq): this package uses the
textbook GE(alpha) convention, where `index = "T"` is GE(1) (Theil T)
and `index = "L"` is GE(0) (mean log deviation). The legacy
[ineq](https://CRAN.R-project.org/package=ineq) package uses the
opposite indexing, so `ineq::Theil(x, parameter = 0)` matches
`iq_theil(x, "T")` and `ineq::Theil(x, parameter = 1)` matches
`iq_theil(x, "L")`.

## References

Theil, H. (1967). *Economics and Information Theory*. Amsterdam:
North-Holland.

Cowell, F. A. (2011). *Measuring Inequality*. 3rd edition. Oxford
University Press.

Shorrocks, A. F. (1980). "The Class of Additively Decomposable
Inequality Measures." *Econometrica*, 48(3), 613–625.

## Examples

``` r
d <- iq_sample_data("income")

# Theil T (GE(1))
iq_theil(d$income, index = "T")
#> 
#> ── Theil T (GE(1)) ─────────────────────────────────────────────────────────────
#> • Value: 0.3307
#> • Observations: 1000

# With bootstrap CIs
iq_theil(d$income, index = "T", ci = TRUE, R = 200)
#> 
#> ── Theil T (GE(1)) ─────────────────────────────────────────────────────────────
#> • Value: 0.3307
#> • Observations: 1000
#> • Bootstrap 95% CI: [0.2797, 0.393]

# Mean log deviation (GE(0))
iq_theil(d$income, index = "L")
#> 
#> ── Theil L / Mean Log Deviation (GE(0)) ────────────────────────────────────────
#> • Value: 0.3241
#> • Observations: 1000

# GE(2): half the squared coefficient of variation
iq_theil(d$income, index = 2)
#> 
#> ── GE(2) ───────────────────────────────────────────────────────────────────────
#> • Value: 0.4951
#> • Observations: 1000
```
