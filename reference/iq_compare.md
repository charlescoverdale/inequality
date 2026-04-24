# Compare inequality measures

Computes all major inequality indices on the same data and returns a
summary table for easy comparison.

## Usage

``` r
iq_compare(x, weights = NULL, na.rm = FALSE, ci = FALSE, R = 1000L)
```

## Arguments

- x:

  Numeric vector of incomes (strictly positive for Theil and Atkinson;
  non-negative for Gini, Palma, Hoover).

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap CIs for the Gini? Default `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

## Value

An S3 object of class `"iq_comparison"` with elements:

- table:

  data.frame with columns `measure` and `value`.

- gini_ci:

  List with `lower` and `upper` (or `NULL`).

- n:

  Integer. Number of observations.

## Examples

``` r
d <- iq_sample_data("income")
iq_compare(d$income)
#> 
#> ── Inequality Comparison (n = 1000) ────────────────────────────────────────────
#> • Gini 0.4300
#> • Theil T (GE1) 0.3307
#> • Theil L (GE0) 0.3241
#> • Atkinson (e=0.5) 0.1506
#> • Atkinson (e=1.0) 0.2768
#> • Palma ratio 2.1528
#> • Hoover 0.3126
#> • P90/P10 7.8282
#> • P80/P20 3.9206
```
