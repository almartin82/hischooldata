# Get available years for Hawaii enrollment data

Returns the range of years for which enrollment data can be fetched from
the Hawaii Department of Education via DBEDT Data Book.

## Usage

``` r
get_available_years()
```

## Value

A list with components:

- min_year:

  Earliest available year (2011)

- max_year:

  Most recent available year (2025)

- years:

  Vector of all available years

- description:

  Human-readable description of the date range

## Details

The `end_year` parameter follows the convention that it represents the
END year of the school year. For example:

- end_year = 2024 means the 2023-24 school year (ending June 2024)

- end_year = 2025 means the 2024-25 school year (ending June 2025)

Note on data sources: DBEDT Data Books are published annually and
typically contain enrollment data for the school year that ends in that
publication year. For example, the 2023 Data Book contains 2023-24
school year data (end_year=2024).

Known gaps:

- end_year 2012 is not available (no 2011 Data Book published)

- end_year 2020 appears in both 2019 and 2020 Data Books (COVID impact)

## Examples

``` r
get_available_years()
#> $min_year
#> [1] 2011
#> 
#> $max_year
#> [1] 2025
#> 
#> $years
#>  [1] 2011 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025
#> 
#> $description
#> [1] "Hawaii enrollment data is available for school years ending 2011 to 2025 (except 2012 - no 2011 Data Book published)"
#> 
```
