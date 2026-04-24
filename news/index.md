# Changelog

## inequality 0.1.0

CRAN release: 2026-04-20

- Initial release.

### Inequality indices

- Gini coefficient with bootstrap or asymptotic (jackknife) confidence
  intervals via
  [`iq_gini()`](https://charlescoverdale.github.io/inequality/reference/iq_gini.md),
  following Davidson (2009).
- Extended S-Gini family with adjustable inequality aversion parameter
  via
  [`iq_sgini()`](https://charlescoverdale.github.io/inequality/reference/iq_sgini.md),
  following Donaldson and Weymark (1980).
- Theil T (GE(1)), mean log deviation (GE(0)), and general GE(alpha) via
  [`iq_theil()`](https://charlescoverdale.github.io/inequality/reference/iq_theil.md),
  following Theil (1967) and Shorrocks (1980).
- Atkinson index with inequality aversion parameter via
  [`iq_atkinson()`](https://charlescoverdale.github.io/inequality/reference/iq_atkinson.md).
- Kolm absolute inequality index via
  [`iq_kolm()`](https://charlescoverdale.github.io/inequality/reference/iq_kolm.md).
- Palma ratio (top 10% / bottom 40% income shares) via
  [`iq_palma()`](https://charlescoverdale.github.io/inequality/reference/iq_palma.md).
- Hoover index (Robin Hood / Pietra index) via
  [`iq_hoover()`](https://charlescoverdale.github.io/inequality/reference/iq_hoover.md).
- Percentile ratios (P90/P10, P80/P20, custom) via
  [`iq_percentile_ratio()`](https://charlescoverdale.github.io/inequality/reference/iq_percentile_ratio.md).

### Distribution and decomposition

- Lorenz curve with base graphics plot method via
  [`iq_lorenz()`](https://charlescoverdale.github.io/inequality/reference/iq_lorenz.md).
- Between-within group decomposition for the generalised entropy family
  via
  [`iq_decompose()`](https://charlescoverdale.github.io/inequality/reference/iq_decompose.md),
  following Bourguignon (1979).
- Income share tabulation (bottom 50%, middle 40%, top 10%, top 1%) via
  [`iq_shares()`](https://charlescoverdale.github.io/inequality/reference/iq_shares.md).
- Concentration index for health inequality with optional
  Erreygers (2009) correction via
  [`iq_concentration()`](https://charlescoverdale.github.io/inequality/reference/iq_concentration.md).
- Wolfson bipolarisation index via
  [`iq_polarisation()`](https://charlescoverdale.github.io/inequality/reference/iq_polarisation.md).

### Poverty

- Foster-Greer-Thorbecke poverty measures (headcount, gap, severity),
  Sen index, and Watts index via
  [`iq_poverty()`](https://charlescoverdale.github.io/inequality/reference/iq_poverty.md).
- Growth incidence curve with plot method via
  [`iq_growth_incidence()`](https://charlescoverdale.github.io/inequality/reference/iq_growth_incidence.md),
  following Ravallion and Chen (2003).

### Fiscal

- Kakwani progressivity index and Reynolds-Smolensky redistribution
  index via
  [`iq_kakwani()`](https://charlescoverdale.github.io/inequality/reference/iq_kakwani.md).

### Utilities

- Side-by-side comparison of all major indices via
  [`iq_compare()`](https://charlescoverdale.github.io/inequality/reference/iq_compare.md).
- All functions accept optional survey weights.
