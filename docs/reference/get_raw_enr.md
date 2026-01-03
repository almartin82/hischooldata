# Download raw enrollment data from Hawaii sources

Downloads school-level enrollment data from HIDOE's official sources.
Uses different download methods based on year:

- 2018+: HIDOE Excel enrollment files

- 2010-2017: DBEDT State Data Book tables

- Pre-2010: Historical DBEDT format

## Usage

``` r
get_raw_enr(end_year)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024)

## Value

Data frame with school-level enrollment data
