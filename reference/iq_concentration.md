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
  correction = c("none", "erreygers", "wagstaff"),
  bounds = c(0, 1),
  na.rm = FALSE,
  ci = FALSE,
  R = 1000L,
  level = 0.95
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

  Character. `"none"` (default) for the standard index; `"erreygers"`
  for the Erreygers (2009) bounded-variable correction; `"wagstaff"` for
  the Wagstaff (2005) normalised index.

- bounds:

  Numeric vector of length 2 giving the lower and upper bounds of `x`.
  Required when `correction = "erreygers"`. Default `c(0, 1)` (suitable
  for binary or proportion variables).

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap confidence intervals? Default `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

## Value

An S3 object of class `"iq_concentration"` with elements:

- value:

  Numeric. The concentration index.

- correction:

  Character. The correction applied.

- n:

  Integer. Number of observations.

- se, ci_lower, ci_upper, level:

  Bootstrap CI fields, `NULL` unless `ci = TRUE`.

## Details

A positive value indicates the outcome is concentrated among the
better-off; a negative value indicates concentration among the
worse-off.

For bounded variables (e.g. binary health indicators), the standard
concentration index has bounds that depend on the mean. Two corrections
are available:

- `correction = "erreygers"`: the Erreygers (2009) corrected index,
  `E = 4 * mu / (b - a) * C`, which has fixed bounds of -1 to 1.

- `correction = "wagstaff"`: the Wagstaff (2005) normalised index,
  `W = C / (1 - mu / b)` for variables bounded above at `b`, which is
  the standard normalisation in much of the health-economics literature.

## References

Wagstaff, A., Paci, P. and van Doorslaer, E. (1991). "On the Measurement
of Inequalities in Health." *Social Science and Medicine*, 33(5),
545–557.

Erreygers, G. (2009). "Correcting the Concentration Index." *Journal of
Health Economics*, 28(2), 504–515.

Wagstaff, A. (2005). "The Bounds of the Concentration Index when the
Variable of Interest is Binary, with an Application to Immunization
Inequality." *Health Economics*, 14(4), 429–432.

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

# With bootstrap CIs
iq_concentration(health_exp, rank = income, ci = TRUE, R = 200)
#> 
#> ── Concentration Index ─────────────────────────────────────────────────────────
#> • Value: 0.3065
#> • Observations: 200
#> • Bootstrap 95% CI: [0.2691, 0.3359]

# Binary outcome with Erreygers correction
sick <- as.numeric(income < median(income)) + rbinom(200, 1, 0.1)
sick <- pmin(sick, 1)
iq_concentration(sick, rank = income, correction = "erreygers")
#> 
#> ── Concentration Index (Erreygers) ─────────────────────────────────────────────
#> • Value: -0.9241
#> • Observations: 200
```
