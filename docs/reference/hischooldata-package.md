# hischooldata: Fetch and Process Hawaii School Data

Downloads and processes school data from the Hawaii Department of
Education (HIDOE) via the DBEDT State Data Book. Provides functions for
fetching enrollment data in tidy format for analysis.

## Hawaii's Unique Structure

Hawaii is the only U.S. state with a single statewide school district.
The Hawaii Department of Education (HIDOE) operates all public schools
directly. Data is organized by county (Honolulu, Hawaii County, Maui,
Kauai) and Charter Schools.

## Main functions

- [`fetch_enr`](https://almartin82.github.io/hischooldata/reference/fetch_enr.md):

  Fetch enrollment data for a school year

- [`fetch_enr_multi`](https://almartin82.github.io/hischooldata/reference/fetch_enr_multi.md):

  Fetch enrollment data for multiple years

- [`get_available_years`](https://almartin82.github.io/hischooldata/reference/get_available_years.md):

  List available school years

## Cache functions

- [`cache_status`](https://almartin82.github.io/hischooldata/reference/cache_status.md):

  View cached data files

- [`clear_cache`](https://almartin82.github.io/hischooldata/reference/clear_cache.md):

  Remove cached data files

## end_year Convention

The end_year parameter represents the END of the school year:

- end_year = 2024 means the 2023-24 school year

- end_year = 2025 means the 2024-25 school year

## Data Sources

Data is sourced from the DBEDT State Data Book:

- DBEDT Data Book: <https://files.hawaii.gov/dbedt/economic/databook/>

- HIDOE: <https://www.hawaiipublicschools.org/>

## See also

Useful links:

- <https://almartin82.github.io/hischooldata/>

- <https://github.com/almartin82/hischooldata>

- Report bugs at <https://github.com/almartin82/hischooldata/issues>

## Author

**Maintainer**: Al Martin <almartin@example.com>
