# Percentile ratio

Computes the ratio of two percentiles of the distribution. Common
choices include P90/P10 (interdecile ratio), P80/P20, and P50/P10.

## Usage

``` r
iq_percentile_ratio(
  x,
  weights = NULL,
  upper = 90,
  lower = 10,
  na.rm = FALSE,
  ci = FALSE,
  R = 1000L,
  level = 0.95
)
```

## Arguments

- x:

  Numeric vector of incomes.

- weights:

  Optional numeric vector of survey weights.

- upper:

  Numeric. Upper percentile (0 to 100). Default `90`.

- lower:

  Numeric. Lower percentile (0 to 100). Default `10`.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap confidence intervals? Default `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

## Value

An S3 object of class `"iq_percentile_ratio"` with elements:

- ratio:

  Numeric. The percentile ratio.

- upper_value:

  Numeric. The value at the upper percentile.

- lower_value:

  Numeric. The value at the lower percentile.

- upper:

  Numeric. The upper percentile used.

- lower:

  Numeric. The lower percentile used.

- n:

  Integer. Number of observations.

- se, ci_lower, ci_upper, level:

  Bootstrap CI fields, `NULL` unless `ci = TRUE`.

## Examples

``` r
d <- iq_sample_data("income")

# P90/P10 (interdecile ratio)
iq_percentile_ratio(d$income)
#> 
#> ── Percentile Ratio (P90/P10) ──────────────────────────────────────────────────
#> • Ratio: 7.83
#> • P90: 101314.08
#> • P10: 12942.26
#> • Observations: 1000

# With bootstrap CIs
iq_percentile_ratio(d$income, ci = TRUE, R = 200)
#> 
#> ── Percentile Ratio (P90/P10) ──────────────────────────────────────────────────
#> • Ratio: 7.83
#> • P90: 101314.08
#> • P10: 12942.26
#> • Observations: 1000
#> • Bootstrap 95% CI: [6.92, 8.48]

# P80/P20
iq_percentile_ratio(d$income, upper = 80, lower = 20)
#> 
#> ── Percentile Ratio (P80/P20) ──────────────────────────────────────────────────
#> • Ratio: 3.92
#> • P80: 70210.92
#> • P20: 17908.32
#> • Observations: 1000
```
