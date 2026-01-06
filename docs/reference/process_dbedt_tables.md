# Process DBEDT Data Book tables

Converts DBEDT table format to standard enrollment format. DBEDT
provides aggregate data at state and county level, organized by grade.
This function parses the enrollment by grade table (Table 3.12 or 3.13
depending on year) and returns tidy enrollment data.

## Usage

``` r
process_dbedt_tables(enr_df, eth_df, end_year)
```

## Arguments

- enr_df:

  Enrollment by grade data frame (Table 3.12 or 3.13)

- eth_df:

  Ethnicity data frame (Table 3.19), optional

- end_year:

  School year end

## Value

Data frame in standard format with county-level enrollment by grade

## Details

Note: Some years (e.g., 2021) contain multiple school years in one
table. This function extracts only the data for the requested end_year.
