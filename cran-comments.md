# CRAN submission comments — inequality 0.2.0

## Reason for this submission

This is an update to inequality 0.1.0, currently on CRAN. It responds to
feedback from Frank Cowell and Emmanuel Flachaire (personal
communication, 1 May 2026) on the 0.1.0 release, which flagged two gaps:
confidence intervals were available only for the Gini, and the package
rejected non-positive values for the Gini and the top shares. A
follow-up internal audit produced several smaller fixes that ship
alongside.

## Summary of changes

* Bootstrap confidence intervals on every inequality measure via
  `ci = TRUE`, with matching `R` and `level` arguments. Twelve functions
  extended. The bootstrap uses probability-proportional resampling, so
  survey weights flow through to the variance, not only the point
  estimate.
* `iq_compare()` runs a single resample loop and propagates `ci_lower`
  and `ci_upper` to every row. The old `gini_ci` field is removed, and
  the table now covers 12 measures, up from 9.
* A new `negatives = c("error", "keep")` argument on the measures that
  are mathematically defined for distributions containing negative
  values. The default is `"error"`, so existing code is unaffected.
  `iq_atkinson()` and `iq_theil()` continue to require strictly positive
  input, since their formulae are undefined at or below zero.
* Several bug fixes where a degenerate input silently returned a
  plausible number: `iq_kakwani()` no longer takes the absolute value of
  post-tax income, and the standard Gini now returns `NA` with a warning
  when the population mean is non-positive rather than returning `0`,
  which conflated "perfect equality" with "undefined".

Full detail in NEWS.md.

## Breaking change

`iq_compare()`'s `gini_ci` field is removed, replaced by the general
`ci_lower` / `ci_upper` columns that now apply to every row.

## R CMD check results

0 errors | 0 warnings | 0 notes (CRAN default settings, R 4.5.2, macOS).

## Downstream dependencies

None on CRAN.
