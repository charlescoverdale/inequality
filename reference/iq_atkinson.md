# Atkinson index

Computes the Atkinson inequality index, which incorporates an explicit
normative judgement about inequality aversion through the parameter
epsilon. Higher epsilon gives more weight to transfers at the bottom of
the distribution.

## Usage

``` r
iq_atkinson(
  x,
  weights = NULL,
  epsilon = 0.5,
  na.rm = FALSE,
  ci = FALSE,
  R = 1000L,
  level = 0.95
)
```

## Arguments

- x:

  Numeric vector of incomes (strictly positive).

- weights:

  Optional numeric vector of survey weights.

- epsilon:

  Numeric. Inequality aversion parameter (\> 0). Default `0.5`. Common
  values: 0.5 (moderate), 1.0 (high), 2.0 (very high aversion).

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap confidence intervals? Default `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

## Value

An S3 object of class `"iq_atkinson"` with elements:

- value:

  Numeric. The Atkinson index (0 to 1).

- epsilon:

  Numeric. The inequality aversion parameter used.

- ede:

  Numeric. The equally distributed equivalent income.

- mean_income:

  Numeric. The mean income.

- n:

  Integer. Number of observations.

- se, ci_lower, ci_upper, level:

  Bootstrap CI fields, `NULL` unless `ci = TRUE`.

## Details

The Atkinson index involves either a power transformation
`x^(1 - epsilon)` or `log(x)` (when `epsilon = 1`) and so requires
strictly positive values. Use the Gini, S-Gini, or Kolm index for
distributions that include zeros or negatives.

## References

Atkinson, A. B. (1970). "On the Measurement of Inequality." *Journal of
Economic Theory*, 2(3), 244–263.

Biewen, M. and Jenkins, S. P. (2006). "Variance Estimation for
Generalized Entropy and Atkinson Inequality Indices: The Complex Survey
Data Case." *Oxford Bulletin of Economics and Statistics*, 68(3),
371–383.

## Examples

``` r
d <- iq_sample_data("income")

# Moderate inequality aversion
iq_atkinson(d$income, epsilon = 0.5)
#> 
#> ── Atkinson Index ──────────────────────────────────────────────────────────────
#> • Value: 0.1506
#> • Epsilon: 0.5
#> • EDE income: 41783.21
#> • Mean income: 49190.12
#> • Observations: 1000

# With bootstrap CIs
iq_atkinson(d$income, epsilon = 0.5, ci = TRUE, R = 200)
#> 
#> ── Atkinson Index ──────────────────────────────────────────────────────────────
#> • Value: 0.1506
#> • Epsilon: 0.5
#> • EDE income: 41783.21
#> • Mean income: 49190.12
#> • Observations: 1000
#> • Bootstrap 95% CI: [0.1328, 0.1712]

# High inequality aversion
iq_atkinson(d$income, epsilon = 1)
#> 
#> ── Atkinson Index ──────────────────────────────────────────────────────────────
#> • Value: 0.2768
#> • Epsilon: 1
#> • EDE income: 35572.94
#> • Mean income: 49190.12
#> • Observations: 1000

# Very high inequality aversion
iq_atkinson(d$income, epsilon = 2)
#> 
#> ── Atkinson Index ──────────────────────────────────────────────────────────────
#> • Value: 0.4765
#> • Epsilon: 2
#> • EDE income: 25750.78
#> • Mean income: 49190.12
#> • Observations: 1000
```
