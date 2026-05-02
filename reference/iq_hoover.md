# Hoover index (Robin Hood index)

Computes the Hoover index, also known as the Robin Hood index or the
Schutz coefficient. It equals the maximum proportion of total income
that would need to be redistributed to achieve perfect equality, or
equivalently, half the mean absolute deviation divided by the mean.

## Usage

``` r
iq_hoover(
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

An S3 object of class `"iq_hoover"` with elements:

- value:

  Numeric. The Hoover index (0 to 1 with non-negative input).

- n:

  Integer. Number of observations.

- se, ci_lower, ci_upper, level:

  Bootstrap CI fields, `NULL` unless `ci = TRUE`.

## Examples

``` r
d <- iq_sample_data("income")
iq_hoover(d$income)
#> 
#> ── Hoover Index ────────────────────────────────────────────────────────────────
#> • Value: 0.3126
#> • Observations: 1000

# With bootstrap CIs
iq_hoover(d$income, ci = TRUE, R = 200)
#> 
#> ── Hoover Index ────────────────────────────────────────────────────────────────
#> • Value: 0.3126
#> • Observations: 1000
#> • Bootstrap 95% CI: [0.2944, 0.3322]

# Perfect equality
iq_hoover(rep(100, 50))
#> 
#> ── Hoover Index ────────────────────────────────────────────────────────────────
#> • Value: 0
#> • Observations: 50
```
