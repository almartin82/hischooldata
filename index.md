# hischooldata

Hawaii is America’s only statewide school district – one state, one
system, no local school boards. This package fetches 15 years of
enrollment data directly from the Hawaii Department of Education so you
can track what’s happening across all four counties and charter schools
with a single function call.

Part of the [njschooldata](https://github.com/almartin82/njschooldata)
family. **[Docs](https://almartin82.github.io/hischooldata/)**

## Data Taxonomy

| Category           | Years     | Function                                                                                                                                                                          | Details                                                                                                                                                   |
|--------------------|-----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Enrollment**     | 2011-2025 | [`fetch_enr()`](https://almartin82.github.io/hischooldata/reference/fetch_enr.md) / [`fetch_enr_multi()`](https://almartin82.github.io/hischooldata/reference/fetch_enr_multi.md) | State, county (Honolulu, Hawaii County, Maui, Kauai), charter; grades PK-12 + SPED + TOTAL; subgroup: `total_enrollment` only (no demographic breakdowns) |
| Assessments        | –         | –                                                                                                                                                                                 | –                                                                                                                                                         |
| Graduation         | –         | –                                                                                                                                                                                 | –                                                                                                                                                         |
| Directory          | –         | –                                                                                                                                                                                 | –                                                                                                                                                         |
| Per-Pupil Spending | –         | –                                                                                                                                                                                 | –                                                                                                                                                         |
| Accountability     | –         | –                                                                                                                                                                                 | –                                                                                                                                                         |
| Chronic Absence    | –         | –                                                                                                                                                                                 | –                                                                                                                                                         |
| EL Progress        | –         | –                                                                                                                                                                                 | –                                                                                                                                                         |
| Special Ed         | –         | –                                                                                                                                                                                 | –                                                                                                                                                         |

> See the full [data category
> taxonomy](https://github.com/almartin82/state-schooldata/blob/main/docs/DATA-CATEGORY-TAXONOMY.md)
> for all 30 categories tracked across the state schooldata project.

## Installation

### R

``` r
# install.packages("remotes")
remotes::install_github("almartin82/hischooldata")
```

### Python

``` bash
pip install git+https://github.com/almartin82/hischooldata.git#subdirectory=pyhischooldata
```

## Quick Start

### R

``` r
library(hischooldata)
library(dplyr)

# Fetch one year
enr_2024 <- fetch_enr(2024, use_cache = TRUE)

# Fetch multiple years
enr_recent <- fetch_enr_multi(2020:2024, use_cache = TRUE)

# Statewide totals
enr_2024 %>%
  filter(type == "STATE", grade_level == "TOTAL")

# County breakdown
enr_2024 %>%
  filter(type == "COUNTY", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(county_name, n_students)
```

### Python

``` python
import pyhischooldata as hi

# Fetch one year
enr_2024 = hi.fetch_enr(2024, use_cache=True)

# Fetch multiple years
enr_recent = hi.fetch_enr_multi([2020, 2021, 2022, 2023, 2024], use_cache=True)

# Statewide totals
enr_2024[
    (enr_2024['type'] == 'STATE') &
    (enr_2024['grade_level'] == 'TOTAL')
]

# County breakdown
(enr_2024[
    (enr_2024['type'] == 'COUNTY') &
    (enr_2024['grade_level'] == 'TOTAL')
]
.sort_values('n_students', ascending=False)
[['county_name', 'n_students']])
```

## Highlights

``` r
library(hischooldata)
library(ggplot2)
library(dplyr)
library(scales)
```

``` r
# Get available years
years <- get_available_years()
if (is.list(years)) {
  max_year <- years$max_year
  min_year <- years$min_year
} else {
  max_year <- max(years)
  min_year <- min(years)
}

# Fetch data for the last 10 available years
year_range <- intersect((max_year - 9):max_year, years$years)
enr <- fetch_enr_multi(year_range, use_cache = TRUE)
enr_current <- fetch_enr(max_year, use_cache = TRUE)
```

------------------------------------------------------------------------

### 7. Charter schools grew 25% since 2016

Hawaii’s charter school enrollment grew from 10,444 to 13,094 students –
a 25% increase while overall enrollment declined.

``` r
charter_trend <- enr %>%
  filter(type == "CHARTER", grade_level == "TOTAL")

stopifnot(nrow(charter_trend) > 0)
print(charter_trend)
#>    end_year district_id                  district_name     county_name    type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter
#> 1      2016          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      10444  NA         district    FALSE     FALSE       TRUE
#> 2      2017          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      10669  NA         district    FALSE     FALSE       TRUE
#> 3      2018          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      11168  NA         district    FALSE     FALSE       TRUE
#> 4      2019          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      11565  NA         district    FALSE     FALSE       TRUE
#> 5      2020          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      11896  NA         district    FALSE     FALSE       TRUE
#> 6      2021          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      12225  NA         district    FALSE     FALSE       TRUE
#> 7      2022          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      12114  NA         district    FALSE     FALSE       TRUE
#> 8      2023          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      12128  NA         district    FALSE     FALSE       TRUE
#> 9      2024          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      12446  NA         district    FALSE     FALSE       TRUE
#> 10     2025          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      13094  NA         district    FALSE     FALSE       TRUE

ggplot(charter_trend, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = "#2C3E50") +
  geom_point(size = 3, color = "#2C3E50") +
  geom_vline(xintercept = 2020.5, linetype = "dashed", color = "red", alpha = 0.5) +
  annotate("text", x = 2020.5, y = Inf, label = "COVID", vjust = 2, color = "red", size = 3) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Charter School Enrollment",
       subtitle = "Growing alternative to traditional public schools",
       x = "School Year", y = "Students") +
  theme_minimal(base_size = 14)
```

![Charter School
Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/charter-growth-1.png)

Charter School Enrollment

------------------------------------------------------------------------

### 5. Kindergarten is shrinking faster than high school

Hawaii’s kindergarten enrollment dropped from ~13,900 to ~11,700 while
Grade 9 grew. The pipeline of students entering the system is narrowing.

``` r
k_trend <- enr %>%
  filter(type == "STATE", grade_level %in% c("K", "09", "12")) %>%
  mutate(grade_label = case_when(
    grade_level == "K" ~ "Kindergarten",
    grade_level == "09" ~ "Grade 9",
    grade_level == "12" ~ "Grade 12"
  ))

stopifnot(nrow(k_trend) > 0)
print(k_trend)
#>    end_year district_id                  district_name county_name  type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter  grade_label
#> 1      2016          HI Hawaii Department of Education State Total STATE           K total_enrollment      13933  NA            state     TRUE     FALSE      FALSE Kindergarten
#> 2      2016          HI Hawaii Department of Education State Total STATE          09 total_enrollment      12341  NA            state     TRUE     FALSE      FALSE      Grade 9
#> 3      2016          HI Hawaii Department of Education State Total STATE          12 total_enrollment       9625  NA            state     TRUE     FALSE      FALSE     Grade 12
#> ...
#> 28     2025          HI Hawaii Department of Education State Total STATE           K total_enrollment      11746  NA            state     TRUE     FALSE      FALSE Kindergarten
#> 29     2025          HI Hawaii Department of Education State Total STATE          09 total_enrollment      14241  NA            state     TRUE     FALSE      FALSE      Grade 9
#> 30     2025          HI Hawaii Department of Education State Total STATE          12 total_enrollment      11905  NA            state     TRUE     FALSE      FALSE     Grade 12

ggplot(k_trend, aes(x = end_year, y = n_students, color = grade_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2020.5, linetype = "dashed", color = "red", alpha = 0.5) +
  annotate("text", x = 2020.5, y = Inf, label = "COVID", vjust = 2, color = "red", size = 3) +
  scale_y_continuous(labels = comma) +
  labs(title = "Kindergarten Shrinking Faster Than High School",
       subtitle = "The pipeline of students is narrowing",
       x = "School Year", y = "Students", color = "") +
  theme_minimal(base_size = 14)
```

![Kindergarten Shrinking Faster Than High
School](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/k-vs-12-1.png)

Kindergarten Shrinking Faster Than High School

------------------------------------------------------------------------

### 11. Honolulu lost 14,170 students while neighbor islands lost only 3,399

Honolulu County (Oahu) has about two-thirds of all students, but
neighbor island counties have maintained enrollment more effectively
during the statewide decline.

``` r
island_comparison <- enr %>%
  filter(grade_level == "TOTAL", type == "COUNTY") %>%
  mutate(island_group = ifelse(county_name == "Honolulu", "Honolulu (Oahu)", "Neighbor Islands")) %>%
  group_by(end_year, island_group) %>%
  summarize(n_students = sum(n_students, na.rm = TRUE), .groups = "drop")

stopifnot(nrow(island_comparison) > 0)
print(island_comparison)
#> # A tibble: 20 x 3
#>    end_year island_group     n_students
#>       <dbl> <chr>                 <dbl>
#>  1     2016 Honolulu (Oahu)      118155
#>  2     2016 Neighbor Islands      53396
#>  3     2017 Honolulu (Oahu)      117203
#>  4     2017 Neighbor Islands      53678
#>  5     2018 Honolulu (Oahu)      115691
#>  6     2018 Neighbor Islands      53978
#>  7     2019 Honolulu (Oahu)      115600
#>  8     2019 Neighbor Islands      54113
#>  9     2020 Honolulu (Oahu)      114980
#> 10     2020 Neighbor Islands      54212
#> 11     2021 Honolulu (Oahu)      111166
#> 12     2021 Neighbor Islands      53050
#> 13     2022 Honolulu (Oahu)      108770
#> 14     2022 Neighbor Islands      52294
#> 15     2023 Honolulu (Oahu)      106515
#> 16     2023 Neighbor Islands      51566
#> 17     2024 Honolulu (Oahu)      105712
#> 18     2024 Neighbor Islands      51150
#> 19     2025 Honolulu (Oahu)      103985
#> 20     2025 Neighbor Islands      49997

ggplot(island_comparison, aes(x = end_year, y = n_students, color = island_group)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 3) +
  geom_vline(xintercept = 2020.5, linetype = "dashed", color = "red", alpha = 0.5) +
  annotate("text", x = 2020.5, y = Inf, label = "COVID", vjust = 2, color = "red", size = 3) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  scale_color_manual(values = c("Honolulu (Oahu)" = "#2C3E50", "Neighbor Islands" = "#1ABC9C")) +
  labs(title = "Honolulu vs Neighbor Islands",
       subtitle = "Oahu dominates but faces steeper decline",
       x = "School Year", y = "Students", color = "") +
  theme_minimal(base_size = 14)
```

![Honolulu vs Neighbor
Islands](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/honolulu-vs-neighbor-1.png)

Honolulu vs Neighbor Islands

------------------------------------------------------------------------

## Explore More

Full analysis with 15 stories: - [Hawaii Enrollment
Trends](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html)
– 15 stories - [Getting started with
hischooldata](https://almartin82.github.io/hischooldata/articles/hischooldata.html) -
[Function
reference](https://almartin82.github.io/hischooldata/reference/)

## Data Notes

### Data Source

Hawaii Department of Education via the [DBEDT State Data
Book](https://files.hawaii.gov/dbedt/economic/databook/) (Tables 3.12
and 3.13).

### Available Years

- **2011-2025** (end_year convention: 2024 = 2023-24 school year)
- **Note:** 2012 data is unavailable (2011 Data Book was not published)

### Data Levels

- **State:** Statewide totals
- **County:** Honolulu, Hawaii, Maui, Kauai
- **Charter:** Statewide charter school aggregate

### Suppression Rules

- Counts under 10 may be suppressed in some years
- SPED (Special Education) data suppressed in 2024-25 per Data Book
  footnote
- No demographic subgroups available (data is enrollment only)

### Census Day

Data represents October 15 enrollment counts (Official Enrollment Count
Day in Hawaii).

### Known Data Quality Issues

- Multi-year tables in some Data Books (e.g., 2021 has both 2020-21 and
  2021-22)
- COVID impact: 2020 Data Book duplicates 2019 data due to disruptions
- Charter school reporting changed over time
