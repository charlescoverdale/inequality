# Generate sample inequality data

Creates synthetic data for testing and demonstrating inequalitykit
functions. Three types are available: individual incomes, a two-period
panel for growth incidence analysis, and grouped incomes for
decomposition.

## Usage

``` r
iq_sample_data(type = c("income", "panel", "grouped"))
```

## Arguments

- type:

  Character. One of `"income"`, `"panel"`, or `"grouped"`.

## Value

A data.frame.

- `"income"`:

  1000 rows with columns `income` and `weight`. Drawn from a lognormal
  distribution (mean log 10.5, sd log 0.8), producing realistic
  income-like data centred around 40,000.

- `"panel"`:

  1000 rows with columns `income_t0`, `income_t1`, `weight`. Two periods
  with heterogeneous growth (bottom grows slower than top, mimicking
  rising inequality).

- `"grouped"`:

  1000 rows with columns `income`, `group`, `weight`. Three groups (A,
  B, C) with different mean incomes for between/within decomposition.

## Examples

``` r
d <- iq_sample_data("income")
head(d)
#>      income weight
#> 1 108745.63      1
#> 2  23115.10      1
#> 3  48557.44      1
#> 4  60251.94      1
#> 5  50182.15      1
#> 6  33359.58      1

panel <- iq_sample_data("panel")
head(panel)
#>   income_t0 income_t1 weight
#> 1 108745.63 124508.50      1
#> 2  23115.10  24345.83      1
#> 3  48557.44  52856.81      1
#> 4  60251.94  64806.34      1
#> 5  50182.15  51703.77      1
#> 6  33359.58  34353.55      1

grouped <- iq_sample_data("grouped")
head(grouped)
#>     income group weight
#> 1 61241.18     A      1
#> 2 19171.52     A      1
#> 3 33452.34     A      1
#> 4 39329.00     A      1
#> 5 34288.35     A      1
#> 6 25243.53     A      1
```
