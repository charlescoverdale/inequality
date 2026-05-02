# Poverty measures

Computes the Foster-Greer-Thorbecke (FGT) family of poverty measures,
plus the Sen index and the Watts index. All measures require a poverty
line.

## Usage

``` r
iq_poverty(
  x,
  line,
  weights = NULL,
  na.rm = FALSE,
  ci = FALSE,
  R = 1000L,
  level = 0.95
)
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

- ci:

  Logical. Compute bootstrap confidence intervals on the headcount, gap,
  severity, and Sen indices? Default `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

## Value

An S3 object of class `"iq_poverty"` with elements:

- headcount:

  Numeric. FGT(0): proportion below the poverty line.

- gap:

  Numeric. FGT(1): average normalised gap.

- severity:

  Numeric. FGT(2): average squared normalised gap.

- sen:

  Numeric. Sen index.

- watts:

  Numeric. Watts index.

- line:

  Numeric. The poverty line used.

- n:

  Integer. Number of observations.

- n_poor:

  Integer. Number of observations below the line.

- ci:

  Optional list of bootstrap CIs for the four standard FGT/Sen measures
  (each a list with `lower` and `upper`).

- level:

  Numeric or `NULL`. Confidence level.

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

# With bootstrap CIs
iq_poverty(d$income, line = p20, ci = TRUE, R = 200)
#> 
#> ── Poverty Measures (line = 17977.94) ──────────────────────────────────────────
#> • Headcount (FGT0): 20%
#> • Poverty gap (FGT1): 0.0639
#> • Severity (FGT2): 0.029
#> • Sen index: 0.0874
#> • Watts index: 0.0891
#> • Poor: 200 of 1000 observations
#> • Bootstrap 95% CIs:
#>   Headcount 95% CI: [0.181, 0.225]
#>   Gap 95% CI: [0.0552, 0.0724]
#>   Severity 95% CI: [0.0239, 0.0338]
#>   Sen 95% CI: [0.0768, 0.099]
```
