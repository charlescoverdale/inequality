# Between-within group decomposition

Decomposes a generalised entropy index into a between-group component
(inequality due to differences in group means) and a within-group
component (inequality within each group). The decomposition is exact:
between + within = total.

## Usage

``` r
iq_decompose(x, group, weights = NULL, index = "T", na.rm = FALSE)
```

## Arguments

- x:

  Numeric vector of incomes (strictly positive).

- group:

  Factor or character vector identifying group membership.

- weights:

  Optional numeric vector of survey weights.

- index:

  Character or numeric. `"T"` for Theil T (GE(1)), `"L"` for mean log
  deviation (GE(0)), or a numeric alpha. Default `"T"`.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_decomposition"` with elements:

- total:

  Numeric. The total GE index.

- between:

  Numeric. The between-group component.

- within:

  Numeric. The within-group component.

- groups:

  data.frame with columns `group`, `n`, `mean_income`, `pop_share`,
  `income_share`, `within_ge`.

- index_name:

  Character. Name of the index used.

## References

Bourguignon, F. (1979). "Decomposable Income Inequality Measures."
*Econometrica*, 47(4), 901–920.

## Examples

``` r
d <- iq_sample_data("grouped")
iq_decompose(d$income, d$group)
#> 
#> ── Between-Within Decomposition (Theil T (GE(1))) ──────────────────────────────
#> • Total: 0.463
#> • Between: 0.116 (25.1%)
#> • Within: 0.347 (74.9%)
#> 
#> ── Group Detail ──
#> 
#> • A: n=400, mean=31572, pop=40%, income=24.1%
#> • B: n=350, mean=44006, pop=35%, income=29.4%
#> • C: n=250, mean=97783, pop=25%, income=46.6%
```
