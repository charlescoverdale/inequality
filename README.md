# inequality

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/inequality)](https://CRAN.R-project.org/package=inequality)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/inequality)](https://CRAN.R-project.org/package=inequality)
[![Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/inequality)](https://CRAN.R-project.org/package=inequality)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

Measure income and wealth inequality in R. Gini coefficients with confidence intervals, Theil indices, Atkinson indices, Palma ratios, Lorenz curves, poverty measures, tax progressivity, and more. All functions accept optional survey weights.


## Installation

```r
# install.packages("devtools")
devtools::install_github("charlescoverdale/inequality")
```


## Why this package?

The main CRAN package for inequality measurement (`ineq`) was last updated in 2014. It computes basic Gini and Theil indices but has no support for survey weights, no confidence intervals, no subgroup decomposition, no poverty measures, no Palma ratio, and no tax progressivity analysis.

`inequality` fills these gaps. You bring income or wealth data from any source (household surveys, tax records, administrative data, simulations) and the package handles measurement, decomposition, and comparison. Every function accepts optional weights, returns a clean S3 object with a print method, and cites the underlying academic paper.


## Quick start

```r
library(inequality)

# Built-in sample data: 1000 synthetic incomes
d <- iq_sample_data("income")

# How unequal is this distribution?
iq_gini(d$income)
#> -- Gini Coefficient --
#> * Gini: 0.43
#> * Observations: 1000

# With confidence intervals
iq_gini(d$income, ci = TRUE)
#> -- Gini Coefficient --
#> * Gini: 0.43
#> * Observations: 1000
#> * Bootstrap 95% CI: [0.4085, 0.453]
```


## What can it do?

### Compare indices side by side

```r
iq_compare(d$income)
#> -- Inequality Comparison (n = 1000) --
#> * Gini              0.4300
#> * Theil T (GE1)     0.3307
#> * Theil L (GE0)     0.3241
#> * Atkinson (e=0.5)  0.1506
#> * Atkinson (e=1.0)  0.2768
#> * Palma ratio       2.1668
#> * Hoover            0.3126
#> * P90/P10           7.83
#> * P80/P20           3.92
```

### Who gets what? Income shares

```r
iq_shares(d$income)
#> -- Income Shares --
#> * Bottom 50%: 21.2% of income (50% of population)
#> * P50-P90:    47.1% of income (40% of population)
#> * P90-P99:    24.0% of income (9% of population)
#> * Top 1%:      6.6% of income (1% of population)
```

### Between-group vs within-group inequality

```r
d <- iq_sample_data("grouped")
iq_decompose(d$income, d$group)
#> -- Between-Within Decomposition (Theil T (GE(1))) --
#> * Total: 0.463
#> * Between: 0.116 (25.1%)
#> * Within: 0.347 (74.9%)
```

### Poverty measurement

```r
d <- iq_sample_data("income")
iq_poverty(d$income, line = 20000)
#> -- Poverty Measures (line = 20000) --
#> * Headcount (FGT0): 18.2%
#> * Poverty gap (FGT1): 0.0521
#> * Severity (FGT2): 0.0198
#> * Sen index: 0.0912
#> * Watts index: 0.0634
```

### Is a tax progressive?

```r
pre_tax <- d$income
tax <- pre_tax * (0.10 + 0.15 * (pre_tax / max(pre_tax)))
iq_kakwani(pre_tax, tax)
#> -- Fiscal Progressivity (Progressive) --
#> * Kakwani index: 0.1832
#> * Reynolds-Smolensky index: 0.0421
```

### Lorenz curve and growth incidence

```r
# Lorenz curve
lc <- iq_lorenz(d$income)
plot(lc)

# Growth incidence curve
panel <- iq_sample_data("panel")
gic <- iq_growth_incidence(panel$income_t0, panel$income_t1)
plot(gic)
```


## Functions

### Inequality indices

| Function | What it measures |
|---|---|
| `iq_gini()` | Gini coefficient (bootstrap or asymptotic CIs) |
| `iq_sgini()` | Extended Gini family (adjustable inequality aversion) |
| `iq_theil()` | Theil T, Theil L, and generalised entropy GE(alpha) |
| `iq_atkinson()` | Atkinson index (with equally distributed equivalent income) |
| `iq_kolm()` | Kolm index (absolute inequality, translation invariant) |
| `iq_palma()` | Palma ratio (top 10% share / bottom 40% share) |
| `iq_hoover()` | Hoover index (Robin Hood index, Pietra index) |
| `iq_percentile_ratio()` | P90/P10, P80/P20, or custom ratios |

### Distribution and decomposition

| Function | What it measures |
|---|---|
| `iq_lorenz()` | Lorenz curve with plot method |
| `iq_shares()` | Income shares by quantile (top 1%, top 10%, etc.) |
| `iq_decompose()` | Between-within group decomposition (GE family) |
| `iq_concentration()` | Concentration index with optional Erreygers correction |
| `iq_polarisation()` | Wolfson bipolarisation index |

### Poverty

| Function | What it measures |
|---|---|
| `iq_poverty()` | FGT family (headcount, gap, severity), Sen and Watts indices |
| `iq_growth_incidence()` | Growth incidence curve (is growth pro-poor?) |

### Fiscal

| Function | What it measures |
|---|---|
| `iq_kakwani()` | Kakwani progressivity + Reynolds-Smolensky redistribution |

### Utilities

| Function | What it does |
|---|---|
| `iq_compare()` | All major indices in one table |
| `iq_sample_data()` | Built-in synthetic data for examples |


## Where to find inequality data

| Source | Coverage | R package |
|--------|----------|-----------|
| [World Bank PovcalNet](https://pip.worldbank.org/) | Global poverty and inequality | `pipr` |
| [World Inequality Database](https://wid.world/) | Top income shares, 100+ countries | `wid` |
| [Luxembourg Income Study](https://www.lisdatacenter.org/) | Harmonised household surveys | `lissyrtools` |
| [OECD Income Distribution](https://stats.oecd.org/) | OECD member Gini, P90/P10, shares | `readoecd` |
| [Eurostat EU-SILC](https://ec.europa.eu/eurostat) | European household income | `eurostat` |
| [UK Family Resources Survey](https://www.gov.uk/government/collections/family-resources-survey--2) | UK income distribution | Download CSV |
| [US Current Population Survey](https://www.census.gov/programs-surveys/cps.html) | US income and poverty | `ipumsr` |
| [UN WIDER WIID](https://www.wider.unu.edu/database/wiid) | Cross-country inequality database | Download CSV |


## Related packages

| Package | Description |
|---------|-------------|
| [inflationkit](https://github.com/charlescoverdale/inflationkit) | Inflation decomposition and core measures |
| [debtkit](https://github.com/charlescoverdale/debtkit) | Debt sustainability analysis |
| [yieldcurves](https://github.com/charlescoverdale/yieldcurves) | Yield curve fitting and analysis |
| [predictset](https://github.com/charlescoverdale/predictset) | Conformal prediction intervals |
| [nowcast](https://github.com/charlescoverdale/nowcast) | Economic nowcasting |


## Issues

Report bugs or request features at [GitHub Issues](https://github.com/charlescoverdale/inequality/issues).


## Keywords

inequality, Gini, Theil, Atkinson, Kolm, Lorenz, Palma, Kakwani, poverty, FGT, decomposition, income distribution, wealth, survey weights, economics, progressivity
