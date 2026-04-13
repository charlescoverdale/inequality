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
