# Kakwani progressivity index

Measures the progressivity of a tax or transfer system. A positive value
indicates progressivity (the rich pay a larger share than their income
share); a negative value indicates regressivity. Zero means
proportional.

## Usage

``` r
iq_kakwani(
  pre_tax,
  tax,
  weights = NULL,
  na.rm = FALSE,
  ci = FALSE,
  R = 1000L,
  level = 0.95,
  negatives = c("error", "keep")
)
```

## Arguments

- pre_tax:

  Numeric vector of pre-tax incomes (non-negative by default).

- tax:

  Numeric vector of tax payments (same length as `pre_tax`). Positive
  values are taxes paid; negative values are transfers received.

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

- ci:

  Logical. Compute bootstrap confidence intervals on the Kakwani and
  Reynolds-Smolensky indices? Default `FALSE`.

- R:

  Integer. Number of bootstrap replicates. Default `1000`.

- level:

  Numeric. Confidence level. Default `0.95`.

- negatives:

  Character. `"error"` (default) aborts on negative pre-tax incomes;
  `"keep"` permits them.

## Value

An S3 object of class `"iq_kakwani"` with elements:

- kakwani:

  Numeric. The Kakwani index (-1 to 1).

- gini_pre:

  Numeric. The pre-tax Gini coefficient.

- concentration_tax:

  Numeric. The concentration coefficient of taxes.

- reynolds_smolensky:

  Numeric. The Reynolds-Smolensky index (pre-tax Gini minus post-tax
  Gini).

- gini_post:

  Numeric. The post-tax Gini coefficient.

- avg_tax_rate:

  Numeric. Average effective tax rate.

- n:

  Integer. Number of observations.

- kakwani_ci, rs_ci:

  Lists with `lower` and `upper` (or `NULL`).

## Details

The Kakwani index equals the concentration coefficient of the tax minus
the pre-tax Gini coefficient: K = C_T - G_pre.

The post-tax Gini is computed on `pre_tax - tax` directly. Households
whose post-tax income is negative are kept as-is, so the post-tax Gini
may exceed 1 in distributions with extreme tax burdens. Pass
`negatives = "error"` to abort on negative pre-tax incomes.

## References

Kakwani, N. C. (1977). "Measurement of Tax Progressivity: An
International Comparison." *The Economic Journal*, 87(345), 71–80.

Reynolds, M. and Smolensky, E. (1977). *Public Expenditures, Taxes, and
the Distribution of Income*. New York: Academic Press.

## Examples

``` r
set.seed(1)
pre <- iq_sample_data("income")$income
# Progressive tax: higher rate for higher incomes
tax <- pre * (0.10 + 0.15 * (pre / max(pre)))
iq_kakwani(pre, tax)
#> 
#> ── Fiscal Progressivity (Progressive) ──────────────────────────────────────────
#> • Kakwani index: 0.0646
#> • Reynolds-Smolensky index: 0.0092
#> • Pre-tax Gini: 0.43
#> • Post-tax Gini: 0.4208
#> • Tax concentration coefficient: 0.4946
#> • Average tax rate: 12.5%
#> • Observations: 1000

# With bootstrap CIs
iq_kakwani(pre, tax, ci = TRUE, R = 200)
#> 
#> ── Fiscal Progressivity (Progressive) ──────────────────────────────────────────
#> • Kakwani index: 0.0646
#> • Reynolds-Smolensky index: 0.0092
#> • Pre-tax Gini: 0.43
#> • Post-tax Gini: 0.4208
#> • Tax concentration coefficient: 0.4946
#> • Average tax rate: 12.5%
#> • Observations: 1000
#> • Bootstrap 95% CIs:
#>   Kakwani: [0.0484, 0.081]
#>   Reynolds-Smolensky: [0.0066, 0.0121]
```
