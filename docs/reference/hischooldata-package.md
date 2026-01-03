# hischooldata: Fetch and Process Hawaii School Data

Downloads and processes school data from the Hawaii Department of
Education (HIDOE). Provides functions for fetching enrollment data and
transforming it into tidy format for analysis.

## Hawaii's Unique Structure

Hawaii is the only U.S. state with a single statewide school district.
The Hawaii Department of Education (HIDOE) operates all public schools
directly, organized into 15 Complex Areas (geographic clusters of
schools).

## Main functions

- [`fetch_enr`](https://almartin82.github.io/hischooldata/reference/fetch_enr.md):

  Fetch enrollment data for a school year

- [`fetch_enr_multi`](https://almartin82.github.io/hischooldata/reference/fetch_enr_multi.md):

  Fetch enrollment data for multiple years

- `tidy_enr`:

  Transform wide data to tidy (long) format

- `id_enr_aggs`:

  Add aggregation level flags

- `enr_grade_aggs`:

  Create grade-level aggregations

## Cache functions

- [`cache_status`](https://almartin82.github.io/hischooldata/reference/cache_status.md):

  View cached data files

- [`clear_cache`](https://almartin82.github.io/hischooldata/reference/clear_cache.md):

  Remove cached data files

## ID System

Hawaii uses a school-based system with state school codes:

- District ID: Always "001" (single statewide district)

- Campus/School IDs: 3-digit codes assigned by HIDOE

- Complex Areas: 15 geographic groupings of schools

## Demographics

Hawaii has unique demographics compared to mainland states:

- Majority Asian and Pacific Islander population

- Native Hawaiian is a significant demographic category

- Part-Hawaiian is tracked separately from Native Hawaiian

- Filipino is the largest single ethnic group in many schools

## Data Sources

Data is sourced from the Hawaii Department of Education:

- HIDOE: <https://www.hawaiipublicschools.org/>

- School Reports:
  <https://hawaiipublicschools.org/data-reports/school-reports/>

- ARCH: <https://arch.k12.hi.us/>

## See also

Useful links:

- <https://almartin82.github.io/hischooldata/>

- <https://github.com/almartin82/hischooldata>

- Report bugs at <https://github.com/almartin82/hischooldata/issues>

## Author

**Maintainer**: Al Martin <almartin@example.com>
