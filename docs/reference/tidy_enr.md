# Transform enrollment data to tidy format

Converts raw/semi-tidy Hawaii enrollment data into the standard tidy
format used across all state schooldata packages.

## Usage

``` r
tidy_enr(df)
```

## Arguments

- df:

  Data frame with raw enrollment data (from get_raw_enr())

## Value

Data frame in standard tidy format with columns:

- end_year:

  School year end (2024 = 2023-24 school year)

- district_id:

  State identifier (HI for Hawaii - single district state)

- district_name:

  District name (Hawaii Department of Education)

- county_name:

  County name (Honolulu, Hawaii County, Maui, Kauai, State Total,
  Charter Schools)

- type:

  Aggregation level (STATE, COUNTY, CHARTER)

- grade_level:

  Grade level (TOTAL, PK, K, 01-12, SPED)

- subgroup:

  Demographic subgroup (only "total_enrollment" available)

- n_students:

  Student count

- pct:

  Percentage (NA for Hawaii - no demographic data)

- aggregation_flag:

  Aggregation level ("state" or "district")

- is_state:

  Logical TRUE for state-level rows

- is_county:

  Logical TRUE for county-level rows

- is_charter:

  Logical TRUE for charter school aggregate rows

## Details

The tidy format has one row per (entity, grade_level, subgroup)
combination, making it easy to filter, group, and analyze.
