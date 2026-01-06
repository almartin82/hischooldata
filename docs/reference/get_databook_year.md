# Map end_year to Data Book year

Internal function to map the requested end_year to the correct DBEDT
Data Book publication year.

## Usage

``` r
get_databook_year(end_year)
```

## Arguments

- end_year:

  School year end (e.g., 2024 for 2023-24 school year)

## Value

Data Book year to fetch from

## Details

The mapping handles several special cases:

- 2020 Data Book has 2019-20 data (duplicate of 2019 Data Book)

- 2021 Data Book has BOTH 2020-21 AND 2021-22 data
