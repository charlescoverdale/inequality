# S-Gini (extended Gini family)

Computes the S-Gini coefficient, a one-parameter generalisation of the
Gini that allows the user to specify how much weight to give different
parts of the distribution. The standard Gini is the special case
`delta = 2`.

## Usage

``` r
iq_sgini(x, weights = NULL, delta = 2, na.rm = FALSE)
```

## Arguments

- x:

  Numeric vector of incomes (non-negative).

- weights:

  Optional numeric vector of survey weights.

- delta:

  Numeric. Inequality aversion parameter (\> 1). Default `2` (standard
  Gini).

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_sgini"` with elements:

- value:

  Numeric. The S-Gini coefficient.

- delta:

  Numeric. The inequality aversion parameter used.

- n:

  Integer. Number of observations.

## Details

Lower delta (approaching 1) gives equal weight everywhere; higher delta
gives more weight to the bottom of the distribution. The standard Gini
(delta = 2) weights by rank position. Delta = 3 or 4 places even more
emphasis on the poorest.

## References

Donaldson, D. and Weymark, J. A. (1980). "A Single-Parameter
Generalization of the Gini Indices of Inequality." *Journal of Economic
Theory*, 22(1), 67–86.

Yitzhaki, S. (1983). "On an Extension of the Gini Inequality Index."
*International Economic Review*, 24(3), 617–628.

## Examples

``` r
d <- iq_sample_data("income")

# Standard Gini (delta = 2)
iq_sgini(d$income, delta = 2)
#> 
#> ── S-Gini (standard Gini, delta = 2) ───────────────────────────────────────────
#> • Value: 0.43
#> • Observations: 1000

# More weight on the bottom of the distribution
iq_sgini(d$income, delta = 3)
#> 
#> ── S-Gini (delta = 3) ──────────────────────────────────────────────────────────
#> • Value: 0.5627
#> • Observations: 1000
```
