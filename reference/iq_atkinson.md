# Atkinson index

Computes the Atkinson inequality index, which incorporates an explicit
normative judgement about inequality aversion through the parameter
epsilon. Higher epsilon gives more weight to transfers at the bottom of
the distribution.

## Usage

``` r
iq_atkinson(x, weights = NULL, epsilon = 0.5, na.rm = FALSE)
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

## References

Atkinson, A. B. (1970). "On the Measurement of Inequality." *Journal of
Economic Theory*, 2(3), 244–263.

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
