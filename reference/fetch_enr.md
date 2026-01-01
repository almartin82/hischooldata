# Fetch Hawaii enrollment data

Downloads and returns enrollment data from the Hawaii Department of
Education (HIDOE).

## Usage

``` r
fetch_enr(end_year, use_cache = TRUE)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024).

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

Data frame with enrollment data

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 enrollment data
enr_2024 <- fetch_enr(2024)

# Force fresh download
enr_fresh <- fetch_enr(2024, use_cache = FALSE)
} # }
```
