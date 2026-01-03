# Download raw enrollment data from Hawaii sources

Downloads school-level enrollment data from HIDOE's official sources.
Uses different download methods based on year:

- 2019+: HIDOE Excel enrollment files (falls back to DBEDT Data Book)

- 2011-2018: DBEDT State Data Book tables

## Usage

``` r
get_raw_enr(end_year)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024)

## Value

Data frame with school-level enrollment data

## Details

The end_year parameter represents the END of the school year. For
example, end_year=2024 requests 2023-24 school year data.
