# inequality 0.1.0

* Initial release.
* Gini coefficient with optional bootstrap confidence intervals via `iq_gini()`.
* Theil T (GE(1)), mean log deviation (GE(0)), and general GE(alpha) via
  `iq_theil()`, following Cowell (2011).
* Atkinson index with inequality aversion parameter via `iq_atkinson()`.
* Palma ratio (top 10% / bottom 40% income shares) via `iq_palma()`.
* Hoover index (Robin Hood index) via `iq_hoover()`.
* Percentile ratios (P90/P10, P80/P20, custom) via `iq_percentile_ratio()`.
* Lorenz curve with base graphics plot method via `iq_lorenz()`.
* Between-within group decomposition for the generalised entropy family
  via `iq_decompose()`, following Bourguignon (1979).
* Income share tabulation (bottom 50%, middle 40%, top 10%, top 1%) via
  `iq_shares()`.
* Concentration index for health inequality via `iq_concentration()`.
* Foster-Greer-Thorbecke poverty measures (headcount, gap, severity), Sen
  index, and Watts index via `iq_poverty()`.
* Growth incidence curve with plot method via `iq_growth_incidence()`,
  following Ravallion and Chen (2003).
* Wolfson bipolarisation index via `iq_polarisation()`.
* Side-by-side comparison of all major indices via `iq_compare()`.
* All functions accept optional survey weights.
