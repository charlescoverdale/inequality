# Kolm index (absolute inequality)

Computes the Kolm index, the only standard inequality measure that is
translation-invariant (absolute). Adding the same amount to every income
leaves the index unchanged. All other indices in this package are
scale-invariant (relative): multiplying every income by the same factor
leaves them unchanged.

## Usage

``` r
iq_kolm(x, weights = NULL, alpha = 1, na.rm = FALSE)
```

## Arguments

- x:

  Numeric vector of incomes.

- weights:

  Optional numeric vector of survey weights.

- alpha:

  Numeric. Inequality aversion parameter (\> 0). Default `1`.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_kolm"` with elements:

- value:

  Numeric. The Kolm index.

- alpha:

  Numeric. The inequality aversion parameter used.

- n:

  Integer. Number of observations.

## Details

Higher alpha gives more weight to inequality at the bottom of the
distribution. The index is always non-negative and equals zero only
under perfect equality.

## References

Kolm, S.-C. (1976). "Unequal Inequalities II." *Journal of Economic
Theory*, 13(1), 82–111.

## Examples

``` r
d <- iq_sample_data("income")
iq_kolm(d$income, alpha = 1)
#> 
#> ── Kolm Index (absolute inequality) ────────────────────────────────────────────
#> • Value: 46736.2301
#> • Alpha: 1
#> • Observations: 1000

# Higher aversion to inequality at the bottom
iq_kolm(d$income, alpha = 2)
#> 
#> ── Kolm Index (absolute inequality) ────────────────────────────────────────────
#> • Value: 46739.684
#> • Alpha: 2
#> • Observations: 1000
```
