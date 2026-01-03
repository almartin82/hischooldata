# Get available years for Hawaii enrollment data

Returns the range of years for which enrollment data can be fetched from
the Hawaii Department of Education.

## Usage

``` r
get_available_years()
```

## Value

A list with components:

- min_year:

  Earliest available year (2010)

- max_year:

  Most recent available year (2025)

- description:

  Human-readable description of the date range

## Examples

``` r
get_available_years()
#> $min_year
#> [1] 2010
#> 
#> $max_year
#> [1] 2025
#> 
#> $description
#> [1] "Hawaii enrollment data is available from 2010 to 2025"
#> 
```
