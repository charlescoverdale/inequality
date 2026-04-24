# Income shares by quantile

Computes the share of total income held by each segment of the
distribution. Default segments: bottom 50%, middle 40%, top 10%, and top
1%.

## Usage

``` r
iq_shares(x, weights = NULL, breaks = c(0.5, 0.9, 0.99, 1), na.rm = FALSE)
```

## Arguments

- x:

  Numeric vector of incomes (non-negative).

- weights:

  Optional numeric vector of survey weights.

- breaks:

  Numeric vector of cumulative population thresholds defining the
  segments. Default `c(0.50, 0.90, 0.99, 1.00)`.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_shares"` with elements:

- shares:

  data.frame with columns `segment`, `pop_share`, `income_share`.

- n:

  Integer. Number of observations.

## Examples

``` r
d <- iq_sample_data("income")
iq_shares(d$income)
#> 
#> ── Income Shares ───────────────────────────────────────────────────────────────
#> • Bottom 50%: 21.2% of income (50% of population)
#> • P50-P90: 47.2% of income (40% of population)
#> • P90-P99: 24.2% of income (9% of population)
#> • Top 1%: 7.3% of income (1% of population)
#> • Observations: 1000

# Custom breaks: quintiles
iq_shares(d$income, breaks = c(0.20, 0.40, 0.60, 0.80, 1.00))
#> 
#> ── Income Shares ───────────────────────────────────────────────────────────────
#> • Bottom 20%: 5% of income (20% of population)
#> • P20-P40: 9.7% of income (20% of population)
#> • P40-P60: 14.5% of income (20% of population)
#> • P60-P80: 22.4% of income (20% of population)
#> • Top 20%: 48.5% of income (20% of population)
#> • Observations: 1000
```
