# Income shares by quantile

Computes the share of total income held by each segment of the
distribution. Default segments: bottom 50%, middle 40%, top 10%, and top
1%.

## Usage

``` r
iq_shares(
  x,
  weights = NULL,
  breaks = c(0.5, 0.9, 0.99, 1),
  na.rm = FALSE,
  ci = FALSE,
  R = 1000L,
  level = 0.95,
  negatives = c("error", "keep")
)
```

## Arguments

- x:

  Numeric vector of incomes.

- weights:

  Optional numeric vector of survey weights.

- breaks:

  Numeric vector of cumulative population thresholds defining the
  segments. Default `c(0.50, 0.90, 0.99, 1.00)`.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap confidence intervals on each share? Default
  `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

- negatives:

  Character. `"error"` (default) aborts on negatives; `"keep"` permits
  them.

## Value

An S3 object of class `"iq_shares"` with elements:

- shares:

  data.frame with columns `segment`, `pop_share`, `income_share`, and
  (when `ci = TRUE`) `ci_lower` and `ci_upper`.

- n:

  Integer. Number of observations.

- level:

  Numeric or `NULL`. Confidence level.

- has_negatives:

  Logical. Whether the input contained negatives.

## Details

Distributions containing negative values can produce shares that fall
outside the unit interval: the bottom segment may have a negative share
(it pulls total income down), and other segments may exceed 100% as a
result. The function returns the raw shares and emits a warning when
negatives are present so the user can interpret accordingly. If the
population total income is non-positive (so shares are not well-defined
at all), the function returns `NA` shares with a warning.

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

# With bootstrap CIs on each share
iq_shares(d$income, ci = TRUE, R = 200)
#> 
#> ── Income Shares ───────────────────────────────────────────────────────────────
#> • Bottom 50%: 21.2% of income (50% of population) [19.9%, 22.5%]
#> • P50-P90: 47.2% of income (40% of population) [45.2%, 49.3%]
#> • P90-P99: 24.2% of income (9% of population) [23%, 25.7%]
#> • Top 1%: 7.3% of income (1% of population) [5.2%, 9.6%]
#> • Observations: 1000
#> • Bootstrap 95% CIs shown in brackets.

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

# Wealth distributions can include negative net worth
wealth <- c(-5000, -1000, 0, 5000, 20000, 80000, 250000, 1e6)
iq_shares(wealth, negatives = "keep")
#> Warning: Input contains negatives; some income shares may fall outside [0, 1].
#> 
#> ── Income Shares ───────────────────────────────────────────────────────────────
#> • Bottom 50%: -0.1% of income (50% of population)
#> • P50-P90: 25.9% of income (40% of population)
#> • P90-P99: 0% of income (9% of population)
#> • Top 1%: 74.1% of income (1% of population)
#> • Observations: 8
#> ! Input contains negatives; shares may fall outside [0, 1].
```
