# hischooldata

**[Documentation](https://almartin82.github.io/hischooldata/)** \|
**[Getting
Started](https://almartin82.github.io/hischooldata/articles/quickstart.html)**
\| **[Enrollment
Trends](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html)**

Fetch and analyze Hawaii school enrollment data from the Hawaii
Department of Education (HIDOE) in R or Python.

## What can you find with hischooldata?

**15 years of enrollment data (2010-2025).** 169,308 students in 2024.
Here are some stories hiding in the numbers:

------------------------------------------------------------------------

### 1. Hawaii is America’s only statewide school district

Unlike every other state, Hawaii operates as a single statewide school
district. No local school boards, no property tax funding. One state,
one system.

``` r
library(hischooldata)
library(dplyr)

enr_2024 <- fetch_enr(2024)

enr_2024 %>%
  filter(is_state, grade_level == "TOTAL", subgroup == "total_enrollment") %>%
  select(n_students)
#>   n_students
#> 1     169308
```

------------------------------------------------------------------------

### 2. Enrollment has been declining for a decade

Hawaii lost 13,076 students since 2015 (from 182,384 to 169,308). High
housing costs push families to the mainland, and birth rates are
falling.

``` r
enr <- fetch_enr_multi(2015:2024)

enr %>%
  filter(is_state, grade_level == "TOTAL", subgroup == "total_enrollment") %>%
  select(end_year, n_students)
#>    end_year n_students
#> 1      2015     182384
#> 2      2016     181995
#> 3      2017     181550
#> 4      2018     180837
#> 5      2019     181278
#> 6      2020     181088
#> 7      2021     176441
#> 8      2022     173178
#> 9      2023     170209
#> 10     2024     169308
```

------------------------------------------------------------------------

### 3. Kindergarten enrollment fluctuates

Kindergarten enrollment dropped sharply during COVID (2021) but has
partially recovered since.

``` r
enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "09", "12")) %>%
  select(end_year, grade_level, n_students) %>%
  tidyr::pivot_wider(names_from = grade_level, values_from = n_students)
#>    end_year     K    09    12
#> 1      2015 10908 12998  9516
#> 2      2016 13933 12341  9625
#> 3      2017 13743 12711  9393
#> 4      2018 13427 12649  9927
#> 5      2019 13485 13024  9554
#> 6      2020 13074 13141  9999
#> 7      2021 11103 13065 10103
#> 8      2022 11456 14010  9832
#> 9      2023 11316 13410  9876
#> 10     2024 11963 12135 11538
```

------------------------------------------------------------------------

### 4. Data available by county and school

The package provides enrollment data at state, county, and school
levels, with grade-level detail.

``` r
# County-level data
enr_2024 %>%
  filter(is_county, grade_level == "TOTAL", subgroup == "total_enrollment") %>%
  select(county_name, n_students) %>%
  arrange(desc(n_students))
#>    county_name n_students
#> 1    Honolulu     145837
#> 2      Hawaii      13188
#> 3      Maui       10216
```

------------------------------------------------------------------------

## Installation

``` r
# install.packages("remotes")
remotes::install_github("almartin82/hischooldata")
```

## Quick start

### R

``` r
library(hischooldata)
library(dplyr)

# Fetch one year
enr_2024 <- fetch_enr(2024)

# Fetch multiple years
enr_recent <- fetch_enr_multi(2020:2024)

# Statewide totals
enr_2024 %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# County breakdown
enr_2024 %>%
  filter(is_county, grade_level == "TOTAL", subgroup == "total_enrollment") %>%
  arrange(desc(n_students)) %>%
  select(county_name, n_students)

# School-level detail
enr_2024 %>%
  filter(subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(district_name, n_students)
```

### Python

``` python
import pyhischooldata as hi

# Fetch one year
enr_2024 = hi.fetch_enr(2024)

# Fetch multiple years
enr_recent = hi.fetch_enr_multi([2020, 2021, 2022, 2023, 2024])

# Statewide totals
enr_2024[
    (enr_2024['is_state'] == True) &
    (enr_2024['subgroup'] == 'total_enrollment') &
    (enr_2024['grade_level'] == 'TOTAL')
]

# County breakdown
(enr_2024[
    (enr_2024['is_county'] == True) &
    (enr_2024['grade_level'] == 'TOTAL') &
    (enr_2024['subgroup'] == 'total_enrollment')
]
.sort_values('n_students', ascending=False)
[['county_name', 'n_students']])

# School-level detail
(enr_2024[
    (enr_2024['subgroup'] == 'total_enrollment') &
    (enr_2024['grade_level'] == 'TOTAL')
]
.sort_values('n_students', ascending=False)
[['district_name', 'n_students']])
```

## Data availability

| Years         | Source                    | Aggregation Levels    | Notes                         |
|---------------|---------------------------|-----------------------|-------------------------------|
| **2018-2025** | HIDOE Official Enrollment | State, County, School | Modern Excel format           |
| **2010-2017** | DBEDT State Data Book     | State, County         | Aggregate data from Data Book |

### What’s available

- **Levels:** State, County (4), and School (~290)
- **Grade levels:** Pre-K through Grade 12
- **Data:** Total enrollment by grade level

### Unique characteristics

- **Single statewide district:** Hawaii has no local school districts

## Data source

Hawaii Department of Education: [HIDOE
Data](https://www.hawaiipublicschools.org/) \| [DBEDT Data
Book](https://files.hawaii.gov/dbedt/economic/databook/)

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data
in Python and R.

**All 50 state packages:**
[github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (<almartin@gmail.com>)

## License

MIT
