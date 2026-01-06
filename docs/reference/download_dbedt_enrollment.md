# Download DBEDT State Data Book enrollment data

Downloads enrollment data from the Hawaii DBEDT State Data Book. Files
are Excel tables with state-level and county-level enrollment by grade.

## Usage

``` r
download_dbedt_enrollment(end_year)
```

## Arguments

- end_year:

  School year end

## Value

Data frame with enrollment data

## Details

Table numbers changed over time:

- 2010-2015: Table 3.12 has enrollment by grade and county

- 2016+: Table 3.13 has enrollment by grade and county

Important: The Data Book publication year is typically one year behind
the school year end. For example, the 2023 Data Book contains 2023-24
school year data (end_year=2024). Use get_databook_year() to map
correctly.
