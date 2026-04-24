# Polarisation index

Computes the Wolfson bipolarisation index, which measures the extent to
which a distribution is bimodal (clustering at the tails) rather than
unimodal. Higher values indicate more polarisation.

## Usage

``` r
iq_polarisation(x, weights = NULL, na.rm = FALSE)
```

## Arguments

- x:

  Numeric vector of incomes (non-negative).

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_polarisation"` with elements:

- wolfson:

  Numeric. The Wolfson polarisation index.

- gini:

  Numeric. The Gini coefficient.

- median:

  Numeric. The weighted median income.

- mean:

  Numeric. The weighted mean income.

- n:

  Integer. Number of observations.

## References

Wolfson, M. C. (1994). "When Inequalities Diverge." *American Economic
Review*, 84(2), 353–358.

Foster, J. E. and Wolfson, M. C. (2010). "Polarization and the Decline
of the Middle Class: Canada and the US." *Journal of Economic
Inequality*, 8(2), 247–273.

## Examples

``` r
d <- iq_sample_data("income")
iq_polarisation(d$income)
#> 
#> ── Polarisation ────────────────────────────────────────────────────────────────
#> • Wolfson index: 0.1988
#> • Gini: 0.43
#> • Median income: 35934.96
#> • Mean income: 49190.12
#> • Observations: 1000
```
