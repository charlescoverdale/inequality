# Concentration index

Computes the concentration index, which measures inequality in a health
(or other) variable across the income distribution. Unlike the Gini
coefficient, the ranking variable and the outcome variable are
different.

## Usage

``` r
iq_concentration(
  x,
  rank,
  weights = NULL,
  correction = c("none", "erreygers"),
  bounds = c(0, 1),
  na.rm = FALSE
)
```

## Arguments

- x:

  Numeric vector of outcome values (e.g. health expenditure).

- rank:

  Numeric vector of ranking values (e.g. income). Must be the same
  length as `x`.

- weights:

  Optional numeric vector of survey weights.

- correction:

  Character. `"none"` (default) for the standard index, or `"erreygers"`
  for the Erreygers (2009) correction for bounded variables.

- bounds:

  Numeric vector of length 2 giving the lower and upper bounds of `x`.
  Required when `correction = "erreygers"`. Default `c(0, 1)` (suitable
  for binary or proportion variables).

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

## Value

An S3 object of class `"iq_concentration"` with elements:

- value:

  Numeric. The concentration index.

- correction:

  Character. The correction applied.

- n:

  Integer. Number of observations.

## Details

A positive value indicates the outcome is concentrated among the
better-off; a negative value indicates concentration among the
worse-off.

For bounded variables (e.g. binary health indicators), the standard
concentration index has bounds that depend on the mean. Use
`correction = "erreygers"` for the Erreygers (2009) corrected index,
which has fixed bounds of -1 to 1 regardless of the mean.

## References

Wagstaff, A., Paci, P. and van Doorslaer, E. (1991). "On the Measurement
of Inequalities in Health." *Social Science and Medicine*, 33(5),
545–557.

Erreygers, G. (2009). "Correcting the Concentration Index." *Journal of
Health Economics*, 28(2), 504–515.

## Examples

``` r
set.seed(1)
income <- rlnorm(200, 10, 0.8)
health_exp <- income * 0.05 + rnorm(200, 500, 100)
iq_concentration(health_exp, rank = income)
#> 
#> ── Concentration Index ─────────────────────────────────────────────────────────
#> • Value: 0.3065
#> • Observations: 200

# Binary outcome with Erreygers correction
sick <- as.numeric(income < median(income)) + rbinom(200, 1, 0.1)
sick <- pmin(sick, 1)
iq_concentration(sick, rank = income, correction = "erreygers")
#> 
#> ── Concentration Index (Erreygers) ─────────────────────────────────────────────
#> • Value: -0.8826
#> • Observations: 200
```
