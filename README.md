# inequality

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/inequality)](https://CRAN.R-project.org/package=inequality)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/inequality)](https://CRAN.R-project.org/package=inequality)
[![Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/inequality)](https://CRAN.R-project.org/package=inequality)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

An R package for measuring income and wealth inequality. Compute Gini coefficients with bootstrap confidence intervals, Theil indices, Atkinson indices, Palma ratios, Lorenz curves, between-within group decompositions, poverty measures, growth incidence curves, and more. All functions accept optional survey weights and work with data from any source.

## Installation

Install from GitHub:

```r
# install.packages("devtools")
devtools::install_github("charlescoverdale/inequality")
```

```r
library(inequality)

# Built-in sample data: 1000 lognormal incomes
d <- iq_sample_data("income")
head(d)
#>     income weight
#> 1  45032.1      1
#> 2  28910.5      1
#> 3  67221.8      1
#> ...

# How unequal is this distribution?
iq_gini(d$income)
#> -- Gini Coefficient --
#> * Gini: 0.3912
#> * Observations: 1000
```


## Why inequality?

The only CRAN package for inequality measurement (`ineq`) was last updated in 2014. It provides basic Gini and Theil calculations but lacks confidence intervals, survey weight support, subgroup decomposition, poverty measures, the Palma ratio, growth incidence curves, or polarisation indices.

`inequality` fills these gaps. You bring income or wealth data from any source (household surveys, tax records, simulations) and the package handles measurement, decomposition, and comparison. Every function accepts optional weights, returns a clean S3 object, and prints a human-readable summary.


## Examples

### How unequal is the distribution?

Compare all major indices side by side:

```r
d <- iq_sample_data("income")
iq_compare(d$income)
#> -- Inequality Comparison (n = 1000) --
#> * Gini              0.3912
#> * Theil T (GE1)     0.2614
#> * Theil L (GE0)     0.2428
#> * Atkinson (e=0.5)  0.1148
#> * Atkinson (e=1.0)  0.2155
#> * Palma ratio       1.4832
#> * Hoover            0.2812
#> * P90/P10           5.21
#> * P80/P20           3.12
```

### Who is getting what?

Income shares by quantile:

```r
iq_shares(d$income)
#> -- Income Shares --
#> * Bottom 50%: 28.4% of income (50% of population)
#> * P50-P90:    43.2% of income (40% of population)
#> * Top 10%:    23.8% of income (10% of population)
#> * Top 1%:      5.6% of income (1% of population)
```

### Is inequality between groups or within groups?

Decompose a Theil index into between-group and within-group components:

```r
d <- iq_sample_data("grouped")
iq_decompose(d$income, d$group)
#> -- Between-Within Decomposition (Theil T (GE(1))) --
#> * Total: 0.2987
#> * Between: 0.0412 (13.8%)
#> * Within: 0.2575 (86.2%)
```

### How much poverty is there?

Foster-Greer-Thorbecke measures with a chosen poverty line:

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

### Is growth pro-poor?

Growth incidence curve comparing two periods:

```r
d <- iq_sample_data("panel")
gic <- iq_growth_incidence(d$income_t0, d$income_t1)
plot(gic)
```

### Lorenz curve

```r
d <- iq_sample_data("income")
lc <- iq_lorenz(d$income)
plot(lc)
```


## Functions

| Function | Description |
|---|---|
| `iq_gini()` | Gini coefficient with optional bootstrap CIs |
| `iq_theil()` | Theil T, Theil L, and GE(alpha) indices |
| `iq_atkinson()` | Atkinson index with inequality aversion parameter |
| `iq_palma()` | Palma ratio (top 10% / bottom 40%) |
| `iq_hoover()` | Hoover index (Robin Hood index) |
| `iq_percentile_ratio()` | P90/P10, P80/P20, or custom percentile ratios |
| `iq_lorenz()` | Lorenz curve data with plot method |
| `iq_decompose()` | Between-within group decomposition (GE family) |
| `iq_shares()` | Income shares by quantile |
| `iq_concentration()` | Concentration index (health inequality) |
| `iq_poverty()` | FGT poverty measures, Sen index, Watts index |
| `iq_growth_incidence()` | Growth incidence curve with plot method |
| `iq_polarisation()` | Wolfson bipolarisation index |
| `iq_compare()` | Side-by-side comparison of all indices |
| `iq_sample_data()` | Synthetic data for examples |


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

inequality, Gini, Theil, Atkinson, Lorenz, Palma, poverty, FGT, decomposition, income distribution, wealth, survey weights, economics
