# Process DBEDT Data Book tables

Converts DBEDT table format to standard enrollment format. DBEDT
provides aggregate data (state/county level), not school-level.

## Usage

``` r
process_dbedt_tables(enr_df, eth_df, end_year)
```

## Arguments

- enr_df:

  Enrollment by grade data frame (Table 3.13)

- eth_df:

  Ethnicity data frame (Table 3.19)

- end_year:

  School year end

## Value

Data frame in standard format
