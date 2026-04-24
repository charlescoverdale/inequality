# Theil index and generalised entropy measures

Computes the Theil T index (GE(1)), Theil L / mean log deviation
(GE(0)), or a generalised entropy index GE(alpha) for any non-negative
alpha.

## Usage

``` r
iq_theil(x, weights = NULL, index = "T", na.rm = FALSE)
```

## Arguments

- x:

  Numeric vector of incomes (strictly positive).

- weights:

  Optional numeric vector of survey weights.

- index:

  Character or numeric. `"T"` for Theil T (GE(1)), `"L"` for mean log
  deviation (GE(0)), or a numeric value for GE(alpha). Default `"T"`.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_theil"` with elements:

- value:

  Numeric. The index value.

- alpha:

  Numeric. The alpha parameter used.

- index_name:

  Character. Human-readable name of the index.

- n:

  Integer. Number of observations.

## Details

Generalised entropy indices are the only class of inequality measures
that are both decomposable by population subgroups and satisfy the
transfer principle. Higher values indicate more inequality.

## References

Theil, H. (1967). *Economics and Information Theory*. Amsterdam:
North-Holland.

Cowell, F. A. (2011). *Measuring Inequality*. 3rd edition. Oxford
University Press.

Shorrocks, A. F. (1980). "The Class of Additively Decomposable
Inequality Measures." *Econometrica*, 48(3), 613–625.

## Examples

``` r
d <- iq_sample_data("income")

# Theil T (GE(1))
iq_theil(d$income, index = "T")
#> 
#> ── Theil T (GE(1)) ─────────────────────────────────────────────────────────────
#> • Value: 0.3307
#> • Observations: 1000

# Mean log deviation (GE(0))
iq_theil(d$income, index = "L")
#> 
#> ── Theil L / Mean Log Deviation (GE(0)) ────────────────────────────────────────
#> • Value: 0.3241
#> • Observations: 1000

# GE(2): half the squared coefficient of variation
iq_theil(d$income, index = 2)
#> 
#> ── GE(2) ───────────────────────────────────────────────────────────────────────
#> • Value: 0.4951
#> • Observations: 1000
```
