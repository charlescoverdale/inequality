# Palma ratio

Computes the Palma ratio: the share of total income received by the top
10 percent divided by the share received by the bottom 40 percent.

## Usage

``` r
iq_palma(
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

  Numeric vector of incomes.

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap confidence intervals? Default `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

- negatives:

  Character. `"error"` (default) aborts on negatives; `"keep"` permits
  them.

## Value

An S3 object of class `"iq_palma"` with elements:

- palma:

  Numeric. The Palma ratio.

- top10_share:

  Numeric. Share of income held by the top 10 percent.

- bottom40_share:

  Numeric. Share of income held by the bottom 40 percent.

- n:

  Integer. Number of observations.

- se, ci_lower, ci_upper, level:

  Bootstrap CI fields, `NULL` unless `ci = TRUE`.

## Details

The Palma ratio is motivated by Palma's (2011) observation that the
"middle" 50 percent (deciles 5–9) tends to capture a remarkably stable
share of income across countries, so inequality is driven by what
happens at the tails. A Palma ratio of 1 means the top 10 percent and
bottom 40 percent receive equal shares.

Distributions containing negative values may produce a non-positive
bottom-40 share, in which case the Palma ratio is undefined. The
function returns `NA` with a warning rather than aborting.

## References

Palma, J. G. (2011). "Homogeneous Middles vs. Heterogeneous Tails, and
the End of the 'Inverted-U': It's All About the Share of the Rich."
*Development and Change*, 42(1), 87–153.

## Examples

``` r
d <- iq_sample_data("income")
iq_palma(d$income)
#> 
#> ── Palma Ratio ─────────────────────────────────────────────────────────────────
#> • Palma ratio: 2.1528
#> • Top 10% share: 31.5%
#> • Bottom 40% share: 14.6%
#> • Observations: 1000

# With bootstrap CIs
iq_palma(d$income, ci = TRUE, R = 200)
#> 
#> ── Palma Ratio ─────────────────────────────────────────────────────────────────
#> • Palma ratio: 2.1528
#> • Top 10% share: 31.5%
#> • Bottom 40% share: 14.6%
#> • Observations: 1000
#> • Bootstrap 95% CI: [1.8718, 2.4882]

# Equal distribution: Palma = 0.25/0.40 = 0.625
iq_palma(rep(100, 100))
#> 
#> ── Palma Ratio ─────────────────────────────────────────────────────────────────
#> • Palma ratio: 0.25
#> • Top 10% share: 10%
#> • Bottom 40% share: 40%
#> • Observations: 100
```
