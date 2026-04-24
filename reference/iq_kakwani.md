# Kakwani progressivity index

Measures the progressivity of a tax or transfer system. A positive value
indicates progressivity (the rich pay a larger share than their income
share); a negative value indicates regressivity. Zero means
proportional.

## Usage

``` r
iq_kakwani(pre_tax, tax, weights = NULL, na.rm = FALSE)
```

## Arguments

- pre_tax:

  Numeric vector of pre-tax incomes (non-negative).

- tax:

  Numeric vector of tax payments (same length as `pre_tax`). Positive
  values are taxes paid; negative values are transfers received.

- weights:

  Optional numeric vector of survey weights.

- na.rm:

  Logical. Remove `NA` values? Default `FALSE`.

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

## Details

The Kakwani index equals the concentration coefficient of the tax minus
the pre-tax Gini coefficient: K = C_T - G_pre.

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
```
