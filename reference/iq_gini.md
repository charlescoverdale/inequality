# Gini coefficient

Computes the Gini coefficient of a distribution, with optional survey
weights and confidence intervals (bootstrap or asymptotic).

## Usage

``` r
iq_gini(
  x,
  weights = NULL,
  na.rm = FALSE,
  ci = FALSE,
  method = c("bootstrap", "asymptotic"),
  R = 1000L,
  level = 0.95
)
```

## Arguments

- x:

  Numeric vector of incomes or values (non-negative).

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute confidence intervals? Default `FALSE`.

- method:

  Character. CI method: `"bootstrap"` (default) or `"asymptotic"`
  (jackknife-based, faster for large samples).

- R:

  Integer. Number of bootstrap replicates (ignored for asymptotic).
  Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

## Value

An S3 object of class `"iq_gini"` with elements:

- gini:

  Numeric. The Gini coefficient.

- n:

  Integer. Number of observations.

- se:

  Numeric or `NULL`. Standard error (asymptotic method only).

- ci_lower:

  Numeric or `NULL`. Lower bound of the CI.

- ci_upper:

  Numeric or `NULL`. Upper bound of the CI.

- level:

  Numeric or `NULL`. Confidence level.

- method:

  Character or `NULL`. CI method used.

## Details

The Gini coefficient ranges from 0 (perfect equality) to 1 (perfect
inequality). It equals twice the area between the Lorenz curve and the
45-degree line.

## References

Gini, C. (1912). "Variabilita e mutabilita." Reprinted in *Memorie di
metodologica statistica* (Ed. Pizetti E, Salvemini, T). Rome: Libreria
Eredi Virgilio Veschi.

Davidson, R. (2009). "Reliable Inference for the Gini Index." *Journal
of Econometrics*, 150(1), 30–40.

## Examples

``` r
d <- iq_sample_data("income")
iq_gini(d$income)
#> 
#> ── Gini Coefficient ────────────────────────────────────────────────────────────
#> • Gini: 0.43
#> • Observations: 1000

# Bootstrap CIs
iq_gini(d$income, ci = TRUE, R = 500)
#> 
#> ── Gini Coefficient ────────────────────────────────────────────────────────────
#> • Gini: 0.43
#> • Observations: 1000
#> • Bootstrap 95% CI: [0.4068, 0.4541]

# Asymptotic CIs (faster for large samples)
iq_gini(d$income, ci = TRUE, method = "asymptotic")
#> 
#> ── Gini Coefficient ────────────────────────────────────────────────────────────
#> • Gini: 0.43
#> • Observations: 1000
#> • Asymptotic 95% CI: [0.4065, 0.4534]

# Perfect equality
iq_gini(rep(100, 50))
#> 
#> ── Gini Coefficient ────────────────────────────────────────────────────────────
#> • Gini: 0
#> • Observations: 50
```
