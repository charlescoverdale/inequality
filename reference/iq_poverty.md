# Poverty measures

Computes the Foster-Greer-Thorbecke (FGT) family of poverty measures,
plus the Sen index and the Watts index. All measures require a poverty
line.

## Usage

``` r
iq_poverty(x, line, weights = NULL, na.rm = FALSE)
```

## Arguments

- x:

  Numeric vector of incomes (non-negative).

- line:

  Numeric. The poverty line. Required.

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_poverty"` with elements:

- headcount:

  Numeric. FGT(0): proportion below the poverty line.

- gap:

  Numeric. FGT(1): average normalised gap.

- severity:

  Numeric. FGT(2): average squared normalised gap.

- sen:

  Numeric. Sen index: headcount \* (gap among poor + Gini among poor \*
  (1 - gap among poor)).

- watts:

  Numeric. Watts index: mean of log(line/x) among the poor.

- line:

  Numeric. The poverty line used.

- n:

  Integer. Number of observations.

- n_poor:

  Integer. Number of observations below the line.

## References

Foster, J., Greer, J. and Thorbecke, E. (1984). "A Class of Decomposable
Poverty Measures." *Econometrica*, 52(3), 761–766.

Sen, A. (1976). "Poverty: An Ordinal Approach to Measurement."
*Econometrica*, 44(2), 219–231.

## Examples

``` r
d <- iq_sample_data("income")
# Poverty line at the 20th percentile
p20 <- quantile(d$income, 0.20)
iq_poverty(d$income, line = p20)
#> 
#> ── Poverty Measures (line = 17977.94) ──────────────────────────────────────────
#> • Headcount (FGT0): 20%
#> • Poverty gap (FGT1): 0.0639
#> • Severity (FGT2): 0.029
#> • Sen index: 0.0874
#> • Watts index: 0.0891
#> • Poor: 200 of 1000 observations
```
