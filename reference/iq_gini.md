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
  level = 0.95,
  negatives = c("error", "keep"),
  normalised = FALSE
)
```

## Arguments

- x:

  Numeric vector of incomes or values.

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

- negatives:

  Character. `"error"` (default) aborts when `x` contains negative
  values; `"keep"` permits negatives.

- normalised:

  Logical. Use the Raffinetti, Siletti and Vernizzi (2017) normalised
  Gini? Default `FALSE`. Only meaningful when `negatives = "keep"`.

## Value

An S3 object of class `"iq_gini"` with elements:

- gini:

  Numeric. The Gini coefficient (or `NA` when undefined).

- n:

  Integer. Number of observations.

- se:

  Numeric or `NULL`. Standard error.

- ci_lower:

  Numeric or `NULL`. Lower bound of the CI.

- ci_upper:

  Numeric or `NULL`. Upper bound of the CI.

- level:

  Numeric or `NULL`. Confidence level.

- method:

  Character or `NULL`. CI method used.

- has_negatives:

  Logical. Whether the input contained negatives.

- normalised:

  Logical. Whether the Raffinetti et al. normalisation was applied.

## Details

For a strictly non-negative distribution the Gini ranges from 0 (perfect
equality) to 1 (perfect inequality) and equals twice the area between
the Lorenz curve and the 45-degree line.

Following feedback from Cowell and Flachaire (personal communication,
2026) the package permits negative values via `negatives = "keep"`. Two
policies are then available:

- `normalised = FALSE` (default): the standard formula is applied. With
  negatives present the index is no longer bounded in the unit interval.
  When the population mean is non-positive the Gini has no inequality
  interpretation and the function returns `NA` with a warning.

- `normalised = TRUE`: the Raffinetti, Siletti and Vernizzi (2017)
  normalised Gini, which rescales the index back into the unit interval
  for distributions containing negatives. The denominator is replaced by
  `mean(|x|)` so the index is well-defined whenever any observation is
  non-zero.

## References

Gini, C. (1912). "Variabilita e mutabilita." Reprinted in *Memorie di
metodologica statistica* (Ed. Pizetti E, Salvemini, T). Rome: Libreria
Eredi Virgilio Veschi.

Davidson, R. (2009). "Reliable Inference for the Gini Index." *Journal
of Econometrics*, 150(1), 30–40.

Raffinetti, E., Siletti, E. and Vernizzi, A. (2017). "Analyzing the
Effects of Negative and Non-negative Values on Income Inequality:
Evidence from the Survey of Household Income and Wealth of the Bank of
Italy (2012)." *Social Indicators Research*, 133(1), 185–207.

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
#> • Bootstrap 95% CI: [0.4059, 0.4557]

# Asymptotic CIs (faster for large samples)
iq_gini(d$income, ci = TRUE, method = "asymptotic")
#> 
#> ── Gini Coefficient ────────────────────────────────────────────────────────────
#> • Gini: 0.43
#> • Observations: 1000
#> • Asymptotic 95% CI: [0.4065, 0.4534]

# Wealth distributions can include negative net worth
wealth <- c(-5000, -1000, 0, 5000, 20000, 80000, 250000)
iq_gini(wealth, negatives = "keep")
#> 
#> ── Gini Coefficient ────────────────────────────────────────────────────────────
#> • Gini: 0.7753
#> • Observations: 7
#> ! Input contains negative values; the standard Gini is not bounded in the unit
#>   interval.

# Same data with the Raffinetti et al. (2017) normalisation
iq_gini(wealth, negatives = "keep", normalised = TRUE)
#> 
#> ── Gini Coefficient (Raffinetti et al. normalised) ─────────────────────────────
#> • Gini: 0.7495
#> • Observations: 7

# Perfect equality
iq_gini(rep(100, 50))
#> 
#> ── Gini Coefficient ────────────────────────────────────────────────────────────
#> • Gini: 0
#> • Observations: 50
```
