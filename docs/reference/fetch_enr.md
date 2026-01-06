# Fetch Hawaii enrollment data

Downloads and returns enrollment data from the Hawaii Department of
Education (HIDOE) via the DBEDT State Data Book.

## Usage

``` r
fetch_enr(end_year, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024). See get_available_years() for the
  range of available years.

- tidy:

  If TRUE (default), returns data in long (tidy) format with subgroup
  column. If FALSE, returns wide format.

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

Data frame with enrollment data by county and grade

## Details

The end_year parameter uses the standard convention: it represents the
END of the school year. For example:

- end_year = 2024 returns data for the 2023-24 school year

- end_year = 2025 returns data for the 2024-25 school year

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 enrollment data (2023-24 school year)
enr_2024 <- fetch_enr(2024)

# Get 2025 enrollment data (2024-25 school year)
enr_2025 <- fetch_enr(2025)

# Force fresh download
enr_fresh <- fetch_enr(2024, use_cache = FALSE)
} # }
```
