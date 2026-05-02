# Compare inequality measures

Computes all major inequality indices on the same data and returns a
summary table for easy comparison.

## Usage

``` r
iq_compare(
  x,
  weights = NULL,
  na.rm = FALSE,
  ci = FALSE,
  R = 1000L,
  level = 0.95,
  negatives = c("error", "keep")
)
```

## Arguments

- x:

  Numeric vector of incomes (strictly positive by default; see
  `negatives`).

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap CIs for every measure in the table? Default
  `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

- negatives:

  Character. `"error"` (default) requires strictly positive `x`;
  `"keep"` permits zero or negative values, with `NA` returned for
  measures that are undefined on those values.

## Value

An S3 object of class `"iq_comparison"` with elements:

- table:

  data.frame with columns `measure`, `value`, and (when `ci = TRUE`)
  `ci_lower` and `ci_upper`.

- n:

  Integer. Number of observations.

- level:

  Numeric or `NULL`. Confidence level.

## Details

When `ci = TRUE` the function runs a single bootstrap loop, recomputing
every measure on each resample. This is far cheaper than calling each
measure with its own `ci = TRUE` and produces a CI for every row of the
table.

By default `iq_compare()` requires strictly positive values because the
Theil and Atkinson rows are mathematically undefined at zero or below.
Pass `negatives = "keep"` to permit zero or negative values: the Theil
and Atkinson rows are returned as `NA` in that case, while the Gini,
S-Gini, Kolm, Wolfson, Palma, Hoover and percentile-ratio rows are
computed using the formulas appropriate for that input.

## Examples

``` r
d <- iq_sample_data("income")
iq_compare(d$income)
#> 
#> ── Inequality Comparison (n = 1000) ────────────────────────────────────────────
#> • Gini 0.4300
#> • S-Gini (delta=3) 0.5627
#> • Theil T (GE1) 0.3307
#> • Theil L (GE0) 0.3241
#> • Atkinson (e=0.5) 0.1506
#> • Atkinson (e=1.0) 0.2768
#> • Kolm (a=1) 46736.2301
#> • Wolfson 0.1988
#> • Palma ratio 2.1528
#> • Hoover 0.3126
#> • P90/P10 7.8282
#> • P80/P20 3.9206

# CIs for every measure in the table (one bootstrap loop, all rows)
iq_compare(d$income, ci = TRUE, R = 200)
#> 
#> ── Inequality Comparison (n = 1000) ────────────────────────────────────────────
#> • Gini 0.4300 [0.406, 0.4559]
#> • S-Gini (delta=3) 0.5627 [0.539, 0.5859]
#> • Theil T (GE1) 0.3307 [0.2797, 0.393]
#> • Theil L (GE0) 0.3241 [0.2874, 0.3636]
#> • Atkinson (e=0.5) 0.1506 [0.1328, 0.1712]
#> • Atkinson (e=1.0) 0.2768 [0.2498, 0.3048]
#> • Kolm (a=1) 46736.2301 [43092.8954, 49430.9832]
#> • Wolfson 0.1988 [0.1862, 0.2174]
#> • Palma ratio 2.1528 [1.8718, 2.4882]
#> • Hoover 0.3126 [0.2944, 0.3322]
#> • P90/P10 7.8282 [6.9233, 8.4754]
#> • P80/P20 3.9206 [3.5389, 4.2616]
#> ℹ Bootstrap 95% CIs in brackets.

# Wealth distributions can include negatives
wealth <- c(-5000, 0, 5000, 20000, 80000, 250000, 1e6)
iq_compare(wealth, negatives = "keep")
#> 
#> ── Inequality Comparison (n = 7) ───────────────────────────────────────────────
#> • Gini 0.7598
#> • S-Gini (delta=3) 0.9344
#> • Theil T (GE1) NA
#> • Theil L (GE0) NA
#> • Atkinson (e=0.5) NA
#> • Atkinson (e=1.0) NA
#> • Kolm (a=1) 197855.1969
#> • Wolfson 3.4776
#> • Palma ratio NA
#> • Hoover 0.6402
#> • P90/P10 -95.0000
#> • P80/P20 -60.6667
#> ! Rows with "NA" are undefined for the input (e.g. Theil and Atkinson require
#>   strictly positive values).
```
