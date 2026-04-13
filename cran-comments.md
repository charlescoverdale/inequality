# CRAN submission comments — inequality 0.1.0

## New submission

This is a new package providing tools for measuring income and wealth
inequality: Gini coefficient with bootstrap CIs, Theil/GE indices, Atkinson
index, Palma ratio, Lorenz curves, between-within group decomposition,
poverty measures (FGT family, Sen, Watts), growth incidence curves, and
Wolfson polarisation. All functions accept optional survey weights.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test suite

150+ expectations across 16 test files. All tests are deterministic (no
network access, fixed random seeds).

## Notes

This package is pure computation with no network access. Dependencies are
minimal: cli (>= 3.6.0), stats, graphics, grDevices.

## Downstream dependencies

None.
