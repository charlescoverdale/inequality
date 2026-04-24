# Hoover index (Robin Hood index)

Computes the Hoover index, also known as the Robin Hood index or the
Schutz coefficient. It equals the maximum proportion of total income
that would need to be redistributed to achieve perfect equality, or
equivalently, half the mean absolute deviation divided by the mean.

## Usage

``` r
iq_hoover(x, weights = NULL, na.rm = FALSE)
```

## Arguments

- x:

  Numeric vector of incomes (non-negative).

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_hoover"` with elements:

- value:

  Numeric. The Hoover index (0 to 1).

- n:

  Integer. Number of observations.

## Examples

``` r
d <- iq_sample_data("income")
iq_hoover(d$income)
#> 
#> ── Hoover Index ────────────────────────────────────────────────────────────────
#> • Value: 0.3126
#> • Observations: 1000

# Perfect equality
iq_hoover(rep(100, 50))
#> 
#> ── Hoover Index ────────────────────────────────────────────────────────────────
#> • Value: 0
#> • Observations: 50
```
