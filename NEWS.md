# inequality 0.2.0

This release responds to feedback from Frank Cowell and Emmanuel Flachaire
(personal communication, 1 May 2026) on the v0.1.0 release. Two gaps were
flagged: confidence intervals were available only for the Gini, and the
package rejected non-positive values for the Gini and the top shares. A
follow-up internal audit produced several smaller fixes that ship together.

## Confidence intervals on every inequality measure

Bootstrap confidence intervals are now available on every inequality
function via `ci = TRUE`. Each function gains `ci`, `R`, and `level`
arguments matching the existing Gini API. Results are returned in
`ci_lower`, `ci_upper`, and `se` fields on the output object and shown by
the print method.

Functions extended: `iq_theil()`, `iq_atkinson()`, `iq_sgini()`,
`iq_palma()`, `iq_hoover()`, `iq_kolm()`, `iq_percentile_ratio()`,
`iq_polarisation()`, `iq_shares()`, `iq_concentration()`, `iq_kakwani()`,
and `iq_poverty()`.

The bootstrap uses probability-proportional resampling, so survey weights
flow through to the variance, not just the point estimate.

## `iq_compare()` runs one bootstrap loop, propagates CIs to every row

When `ci = TRUE`, `iq_compare()` now runs a single resample loop and
attaches `ci_lower` and `ci_upper` columns to every row of the table. The
old `gini_ci` field is removed. The table now also covers S-Gini,
Kolm, and Wolfson (12 measures, up from 9).

## Negative values are now supported via `negatives = "keep"`

Functions that are mathematically defined for distributions containing
negative values now accept `negatives = c("error", "keep")`, with
`"error"` as the default for back-compatibility. With `negatives = "keep"`:

- `iq_gini()` and `iq_sgini()` permit negatives; the index is still
  computed by the standard formula but is no longer bounded in [0, 1].
  The print method emits a note when the input contains negatives.
- `iq_shares()` permits negatives; segment shares may fall outside
  [0, 1] and a warning is issued. If total income is non-positive, the
  function returns `NA` shares with a warning.
- `iq_palma()`, `iq_hoover()`, and `iq_polarisation()` similarly accept
  negatives.

`iq_kolm()` already worked for negative values and is unchanged.

`iq_atkinson()` and `iq_theil()` continue to require strictly positive
values: they involve `log(x)` or `x^(1 - epsilon)` for which the formula
is mathematically undefined at zero or below. The error message now
documents this explicitly.

## Bug fixes

- `iq_kakwani()` no longer takes the absolute value of post-tax income
  before computing the post-tax Gini. Households whose post-tax income is
  negative are now reflected honestly in the Reynolds-Smolensky index.
- `iq_palma()` and `iq_polarisation()` now warn rather than abort when
  the relevant denominator is non-positive (returning `NA`).
- The standard Gini now returns `NA` (with a warning) when the population
  mean is non-positive. Previously the function returned `0` when `mu == 0`,
  which conflated "perfect equality" with "undefined". With `negatives = "keep"`
  set, the user is pointed at `normalised = TRUE` for the Raffinetti et
  al. (2017) bounded variant.
- The Watts poverty index drops observations with `x = 0` from the Watts
  sum (since `log(line / 0)` diverges) and emits a one-time warning. FGT
  measures and the Sen index continue to include all poor observations.
- `iq_percentile_ratio()` now warns when the lower percentile is negative,
  since the resulting ratio sign-flips and has no inequality interpretation.
- The error message for measures that require strictly positive input
  (Theil, Atkinson, decompose, growth_incidence) no longer suggests
  setting `negatives = "keep"`, which those wrappers do not expose.
  Instead the message points the user at measures that admit zero or
  negative support.

## New features (audit follow-up)

- `iq_gini()` gains a `normalised` flag implementing the Raffinetti,
  Siletti and Vernizzi (2017) Gini variant, which is bounded in [-1, 1]
  for distributions containing negative values.
- `iq_compare()` gains a `negatives` argument. With `negatives = "keep"`
  it permits zero or negative input and returns `NA` for the Theil and
  Atkinson rows (which are mathematically undefined for non-positive
  values), while still computing Gini, S-Gini, Kolm, Wolfson, Hoover,
  Palma and percentile-ratio rows.
- `iq_concentration()` gains a `correction = "wagstaff"` option for
  the Wagstaff (2005) normalised concentration index, alongside the
  existing Erreygers (2009) correction.
- `?iq_theil` now documents the convention difference vs the legacy
  `ineq` package (`ineq::Theil(x, parameter = 0)` corresponds to
  GE(1) / Theil T here, not to GE(0) / Theil L).
- New `tests/testthat/test-axioms.R` locks in scale invariance, Kolm
  translation invariance, Pigou-Dalton transfer principle, anonymity,
  parameter monotonicity, decomposition exactness, the Erreygers and
  Wagstaff bounds, and bootstrap nominal coverage.
- New `tests/testthat/test-cross-package.R` cross-checks Gini, Theil,
  and Atkinson values against the legacy `ineq` package on a fixed seed.
  Skipped when `ineq` is not installed and on CRAN.

## Acknowledgements

Thanks to Frank Cowell and Emmanuel Flachaire for the careful read and
the two-line list of gaps.

# inequality 0.1.0

* Initial release.

## Inequality indices

* Gini coefficient with bootstrap or asymptotic (jackknife) confidence
  intervals via `iq_gini()`, following Davidson (2009).
* Extended S-Gini family with adjustable inequality aversion parameter
  via `iq_sgini()`, following Donaldson and Weymark (1980).
* Theil T (GE(1)), mean log deviation (GE(0)), and general GE(alpha) via
  `iq_theil()`, following Theil (1967) and Shorrocks (1980).
* Atkinson index with inequality aversion parameter via `iq_atkinson()`.
* Kolm absolute inequality index via `iq_kolm()`.
* Palma ratio (top 10% / bottom 40% income shares) via `iq_palma()`.
* Hoover index (Robin Hood / Pietra index) via `iq_hoover()`.
* Percentile ratios (P90/P10, P80/P20, custom) via `iq_percentile_ratio()`.

## Distribution and decomposition

* Lorenz curve with base graphics plot method via `iq_lorenz()`.
* Between-within group decomposition for the generalised entropy family
  via `iq_decompose()`, following Bourguignon (1979).
* Income share tabulation (bottom 50%, middle 40%, top 10%, top 1%) via
  `iq_shares()`.
* Concentration index for health inequality with optional Erreygers (2009)
  correction via `iq_concentration()`.
* Wolfson bipolarisation index via `iq_polarisation()`.

## Poverty

* Foster-Greer-Thorbecke poverty measures (headcount, gap, severity), Sen
  index, and Watts index via `iq_poverty()`.
* Growth incidence curve with plot method via `iq_growth_incidence()`,
  following Ravallion and Chen (2003).

## Fiscal

* Kakwani progressivity index and Reynolds-Smolensky redistribution index
  via `iq_kakwani()`.

## Utilities

* Side-by-side comparison of all major indices via `iq_compare()`.
* All functions accept optional survey weights.
