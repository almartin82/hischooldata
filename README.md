# hischooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/hischooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/hischooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/hischooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/hischooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/hischooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/hischooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Hawaii is America's only statewide school district -- one state, one system, no local school boards. This package fetches 15 years of enrollment data directly from the Hawaii Department of Education so you can track what's happening across all four counties and charter schools with a single function call.

Part of the [njschooldata](https://github.com/almartin82/njschooldata) family.

**[Full documentation](https://almartin82.github.io/hischooldata/)** — all 15 stories with interactive charts, getting-started guide, and complete function reference.

## Highlights

```r
library(hischooldata)
library(ggplot2)
library(dplyr)
library(scales)

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

---

### 1. Charter schools grew 25% since 2016

Hawaii's charter school enrollment grew from 10,444 to 13,094 students -- a 25% increase while overall enrollment declined.

```r
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
```

![Charter School Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/charter-growth-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#charter-schools-grew-25-since-2016)

---

### 2. Kindergarten is shrinking faster than high school

Hawaii's kindergarten enrollment dropped from ~13,900 to ~11,700 while Grade 9 grew. The pipeline of students entering the system is narrowing.

```r
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
```

![Kindergarten Shrinking Faster Than High School](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/k-vs-12-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#kindergarten-is-shrinking-faster-than-high-school)

---

### 3. Maui lost 2,346 students since 2016 -- wildfires compound the decline

Maui County has seen enrollment drop from 21,080 to 18,734 since 2016. The 2023 Lahaina wildfire added new challenges to an already declining population.

```r
maui_trend <- enr %>%
  filter(grade_level == "TOTAL", county_name == "Maui")

stopifnot(nrow(maui_trend) > 0)
print(maui_trend)
#>     end_year district_id                  district_name county_name   type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter
#> 49      2016          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      21080  NA         district    FALSE      TRUE      FALSE
#> 145     2017          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      21155  NA         district    FALSE      TRUE      FALSE
#> 241     2018          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      21259  NA         district    FALSE      TRUE      FALSE
#> 337     2019          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      21185  NA         district    FALSE      TRUE      FALSE
#> 433     2020          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      21229  NA         district    FALSE      TRUE      FALSE
#> 529     2021          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      20535  NA         district    FALSE      TRUE      FALSE
#> 625     2022          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      19963  NA         district    FALSE      TRUE      FALSE
#> 721     2023          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      19615  NA         district    FALSE      TRUE      FALSE
#> 814     2024          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      19541  NA         district    FALSE      TRUE      FALSE
#> 904     2025          HI Hawaii Department of Education        Maui COUNTY       TOTAL total_enrollment      18734  NA         district    FALSE      TRUE      FALSE
```

![Maui County Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/maui-n_students-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#maui-lost-2346-students-since-2016----wildfires-compound-the-decline)

---

## Data Taxonomy

| Category | Years | Function | Details |
|----------|-------|----------|---------|
| **Enrollment** | 2011-2025 | `fetch_enr()` / `fetch_enr_multi()` | State, county (Honolulu, Hawaii County, Maui, Kauai), charter; grades PK-12 + SPED + TOTAL; subgroup: `total_enrollment` only (no demographic breakdowns) |
| Assessments | -- | -- | -- |
| Graduation | -- | -- | -- |
| Directory | -- | -- | -- |
| Per-Pupil Spending | -- | -- | -- |
| Accountability | -- | -- | -- |
| Chronic Absence | -- | -- | -- |
| EL Progress | -- | -- | -- |
| Special Ed | -- | -- | -- |

> See [DATA-CATEGORY-TAXONOMY.md](DATA-CATEGORY-TAXONOMY.md) for what each category covers.

## Quick Start

### R

```r
# install.packages("remotes")
remotes::install_github("almartin82/hischooldata")
```

```r
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

```bash
pip install git+https://github.com/almartin82/hischooldata.git#subdirectory=pyhischooldata
```

```python
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

## Explore More

- [Full documentation](https://almartin82.github.io/hischooldata/) -- all 15 stories with interactive charts
- [Getting started with hischooldata](https://almartin82.github.io/hischooldata/articles/hischooldata.html)
- [Function reference](https://almartin82.github.io/hischooldata/reference/)

## Data Notes

### Data Source

Hawaii Department of Education via the [DBEDT State Data Book](https://files.hawaii.gov/dbedt/economic/databook/) (Tables 3.12 and 3.13).

### Available Years

- **2011-2025** (end_year convention: 2024 = 2023-24 school year)
- **Note:** 2012 data is unavailable (2011 Data Book was not published)

### Data Levels

- **State:** Statewide totals
- **County:** Honolulu, Hawaii, Maui, Kauai
- **Charter:** Statewide charter school aggregate

### Suppression Rules

- Counts under 10 may be suppressed in some years
- SPED (Special Education) data suppressed in 2024-25 per Data Book footnote
- No demographic subgroups available (data is enrollment only)

### Census Day

Data represents October 15 enrollment counts (Official Enrollment Count Day in Hawaii).

### Known Data Quality Issues

- Multi-year tables in some Data Books (e.g., 2021 has both 2020-21 and 2021-22)
- COVID impact: 2020 Data Book duplicates 2019 data due to disruptions
- Charter school reporting changed over time

## Deeper Dive

---

### 4. Hawaii is America's only statewide school district

Unlike every other state, Hawaii operates as a single statewide school district with approximately 290 schools. No local school boards, no property tax funding. One state, one system.

```r
statewide <- enr_current %>%
  filter(type == "STATE", grade_level == "TOTAL") %>%
  select(n_students)
stopifnot(nrow(statewide) > 0)

# Count counties (Hawaii is organized by county, not individual schools in this data)
n_counties <- enr_current %>%
  filter(type == "COUNTY", grade_level == "TOTAL") %>%
  nrow()

cat("Total students:", format(statewide$n_students, big.mark = ","), "\n")
cat("Counties served:", n_counties, "(plus Charter Schools)\n")
#> Total students: 167,076
#> Counties served: 4 (plus Charter Schools)
```

---

### 5. Enrollment dropped ~15,000 students since 2016

Hawaii lost nearly 15,000 students since 2016. High housing costs push families to the mainland, and birth rates are falling.

```r
state_trend <- enr %>%
  filter(type == "STATE", grade_level == "TOTAL")

stopifnot(nrow(state_trend) > 0)
print(state_trend)
#>     end_year district_id                  district_name county_name  type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter
#> 1       2016          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     181995  NA            state     TRUE     FALSE      FALSE
#> 97      2017          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     181550  NA            state     TRUE     FALSE      FALSE
#> 193     2018          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     180837  NA            state     TRUE     FALSE      FALSE
#> 289     2019          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     181278  NA            state     TRUE     FALSE      FALSE
#> 385     2020          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     181088  NA            state     TRUE     FALSE      FALSE
#> 481     2021          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     176441  NA            state     TRUE     FALSE      FALSE
#> 577     2022          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     173178  NA            state     TRUE     FALSE      FALSE
#> 673     2023          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     170209  NA            state     TRUE     FALSE      FALSE
#> 769     2024          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     169308  NA            state     TRUE     FALSE      FALSE
#> 859     2025          HI Hawaii Department of Education State Total STATE       TOTAL total_enrollment     167076  NA            state     TRUE     FALSE      FALSE
```

![Hawaii Public School Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/n_students-decline-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#enrollment-dropped-15000-students-since-2016)

---

### 6. Enrollment by County

Hawaii's single statewide district serves four counties plus charter schools. Honolulu (Oahu) dominates enrollment, with about two-thirds of all students.

```r
county_enr <- enr_current %>%
  filter(grade_level == "TOTAL", type %in% c("COUNTY", "CHARTER")) %>%
  mutate(county_label = reorder(county_name, -n_students))

stopifnot(nrow(county_enr) > 0)
print(county_enr)
#>    end_year district_id                  district_name     county_name    type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter
#> 18     2025          HI Hawaii Department of Education        Honolulu  COUNTY       TOTAL total_enrollment     103985  NA         district    FALSE      TRUE      FALSE
#> 35     2025          HI Hawaii Department of Education   Hawaii County  COUNTY       TOTAL total_enrollment      22715  NA         district    FALSE      TRUE      FALSE
#> 52     2025          HI Hawaii Department of Education            Maui  COUNTY       TOTAL total_enrollment      18734  NA         district    FALSE      TRUE      FALSE
#> 69     2025          HI Hawaii Department of Education           Kauai  COUNTY       TOTAL total_enrollment       8548  NA         district    FALSE      TRUE      FALSE
#> 86     2025          HI Hawaii Department of Education Charter Schools CHARTER       TOTAL total_enrollment      13094  NA         district    FALSE     FALSE       TRUE
```

![Hawaii Enrollment by County](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/county-distribution-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#enrollment-by-county)

---

### 7. COVID hit enrollment hard -- 4,647 students lost in one year

When the pandemic struck, families moved to the mainland or shifted to private schools. Hawaii lost 4,647 students (2.6%) between 2020 and 2021.

```r
# Show year-over-year change during COVID
covid_change <- enr %>%
  filter(end_year %in% c(2020, 2021), grade_level == "TOTAL", type == "STATE") %>%
  select(end_year, n_students)
stopifnot(nrow(covid_change) == 2)

change <- diff(covid_change$n_students)
pct_change <- change / covid_change$n_students[1] * 100
cat("Enrollment change 2020-2021:", format(change, big.mark = ","),
    sprintf("(%.1f%%)", pct_change), "\n")
#> Enrollment change 2020-2021: -4,647 (-2.6%)
```

---

### 8. Private school competition is fierce

Hawaii has one of the highest private school enrollment rates in the nation. Kamehameha Schools, Punahou, and Iolani draw thousands of students who might otherwise attend public schools.

```r
# Public enrollment as context
public_total <- enr_current %>%
  filter(type == "STATE", grade_level == "TOTAL") %>%
  pull(n_students)
stopifnot(length(public_total) == 1)

cat("Public school enrollment:", format(public_total, big.mark = ","), "\n")
cat("Estimated private school students: ~35,000\n")
cat("Private school share: ~",
    round(35000 / (public_total + 35000) * 100, 1), "%\n", sep = "")
#> Public school enrollment: 167,076
#> Estimated private school students: ~35,000
#> Private school share: ~17.3%
```

---

### 9. County trends over time

Each county shows its own enrollment trend. Honolulu (Oahu) dominates overall enrollment but has seen the largest absolute decline.

```r
county_trend <- enr %>%
  filter(grade_level == "TOTAL", type == "COUNTY")

stopifnot(nrow(county_trend) > 0)
print(county_trend)
#>     end_year district_id                  district_name   county_name   type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter
#> 17      2016          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     118155  NA         district    FALSE      TRUE      FALSE
#> 33      2016          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      22949  NA         district    FALSE      TRUE      FALSE
#> 49      2016          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      21080  NA         district    FALSE      TRUE      FALSE
#> 65      2016          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       9367  NA         district    FALSE      TRUE      FALSE
#> 113     2017          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     117203  NA         district    FALSE      TRUE      FALSE
#> 129     2017          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      23131  NA         district    FALSE      TRUE      FALSE
#> 145     2017          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      21155  NA         district    FALSE      TRUE      FALSE
#> 161     2017          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       9392  NA         district    FALSE      TRUE      FALSE
#> 209     2018          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     115691  NA         district    FALSE      TRUE      FALSE
#> 225     2018          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      23308  NA         district    FALSE      TRUE      FALSE
#> 241     2018          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      21259  NA         district    FALSE      TRUE      FALSE
#> 257     2018          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       9411  NA         district    FALSE      TRUE      FALSE
#> 305     2019          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     115600  NA         district    FALSE      TRUE      FALSE
#> 321     2019          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      23563  NA         district    FALSE      TRUE      FALSE
#> 337     2019          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      21185  NA         district    FALSE      TRUE      FALSE
#> 353     2019          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       9365  NA         district    FALSE      TRUE      FALSE
#> 401     2020          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     114980  NA         district    FALSE      TRUE      FALSE
#> 417     2020          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      23622  NA         district    FALSE      TRUE      FALSE
#> 433     2020          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      21229  NA         district    FALSE      TRUE      FALSE
#> 449     2020          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       9361  NA         district    FALSE      TRUE      FALSE
#> 497     2021          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     111166  NA         district    FALSE      TRUE      FALSE
#> 513     2021          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      23375  NA         district    FALSE      TRUE      FALSE
#> 529     2021          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      20535  NA         district    FALSE      TRUE      FALSE
#> 545     2021          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       9140  NA         district    FALSE      TRUE      FALSE
#> 593     2022          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     108770  NA         district    FALSE      TRUE      FALSE
#> 609     2022          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      23326  NA         district    FALSE      TRUE      FALSE
#> 625     2022          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      19963  NA         district    FALSE      TRUE      FALSE
#> 641     2022          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       9005  NA         district    FALSE      TRUE      FALSE
#> 689     2023          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     106515  NA         district    FALSE      TRUE      FALSE
#> 705     2023          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      23127  NA         district    FALSE      TRUE      FALSE
#> 721     2023          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      19615  NA         district    FALSE      TRUE      FALSE
#> 737     2023          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       8824  NA         district    FALSE      TRUE      FALSE
#> 784     2024          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     105712  NA         district    FALSE      TRUE      FALSE
#> 799     2024          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      22880  NA         district    FALSE      TRUE      FALSE
#> 814     2024          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      19541  NA         district    FALSE      TRUE      FALSE
#> 829     2024          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       8729  NA         district    FALSE      TRUE      FALSE
#> 874     2025          HI Hawaii Department of Education      Honolulu COUNTY       TOTAL total_enrollment     103985  NA         district    FALSE      TRUE      FALSE
#> 889     2025          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      22715  NA         district    FALSE      TRUE      FALSE
#> 904     2025          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      18734  NA         district    FALSE      TRUE      FALSE
#> 919     2025          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       8548  NA         district    FALSE      TRUE      FALSE
```

![Enrollment by County](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/county-trends-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#county-trends-over-time)

---

### 10. Special education enrollment

Hawaii tracks special education enrollment separately from regular grades in the DBEDT data. SPED data is suppressed in the most recent year per the Data Book footnote.

```r
sped <- enr_current %>%
  filter(type == "STATE", grade_level == "SPED")

if (nrow(sped) > 0) {
  total <- enr_current %>%
    filter(type == "STATE", grade_level == "TOTAL") %>%
    pull(n_students)
  cat("Special education students:", format(sped$n_students, big.mark = ","), "\n")
  cat("Percent of total enrollment:", sprintf("%.1f%%", sped$n_students / total * 100), "\n")
} else {
  cat("Special education data not separately reported for this year.\n")
}
#> Special education data not separately reported for this year.
```

---

### 11. Grade level distribution

Hawaii's enrollment by grade shows the typical K-12 distribution, with Grade 9 as the largest grade in 2025.

```r
grade_dist <- enr_current %>%
  filter(type == "STATE", !grade_level %in% c("TOTAL", "SPED")) %>%
  mutate(grade_level = factor(grade_level, levels = c("PK", "K", sprintf("%02d", 1:12))))

stopifnot(nrow(grade_dist) > 0)
print(grade_dist)
#>    end_year district_id                  district_name county_name  type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter
#> 2      2025          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1736  NA            state     TRUE     FALSE      FALSE
#> 3      2025          HI Hawaii Department of Education State Total STATE           K total_enrollment      11746  NA            state     TRUE     FALSE      FALSE
#> 4      2025          HI Hawaii Department of Education State Total STATE          01 total_enrollment      12451  NA            state     TRUE     FALSE      FALSE
#> 5      2025          HI Hawaii Department of Education State Total STATE          02 total_enrollment      13115  NA            state     TRUE     FALSE      FALSE
#> 6      2025          HI Hawaii Department of Education State Total STATE          03 total_enrollment      13336  NA            state     TRUE     FALSE      FALSE
#> 7      2025          HI Hawaii Department of Education State Total STATE          04 total_enrollment      12822  NA            state     TRUE     FALSE      FALSE
#> 8      2025          HI Hawaii Department of Education State Total STATE          05 total_enrollment      13376  NA            state     TRUE     FALSE      FALSE
#> 9      2025          HI Hawaii Department of Education State Total STATE          06 total_enrollment      13312  NA            state     TRUE     FALSE      FALSE
#> 10     2025          HI Hawaii Department of Education State Total STATE          07 total_enrollment      12797  NA            state     TRUE     FALSE      FALSE
#> 11     2025          HI Hawaii Department of Education State Total STATE          08 total_enrollment      12675  NA            state     TRUE     FALSE      FALSE
#> 12     2025          HI Hawaii Department of Education State Total STATE          09 total_enrollment      14241  NA            state     TRUE     FALSE      FALSE
#> 13     2025          HI Hawaii Department of Education State Total STATE          10 total_enrollment      10938  NA            state     TRUE     FALSE      FALSE
#> 14     2025          HI Hawaii Department of Education State Total STATE          11 total_enrollment      12626  NA            state     TRUE     FALSE      FALSE
#> 15     2025          HI Hawaii Department of Education State Total STATE          12 total_enrollment      11905  NA            state     TRUE     FALSE      FALSE
```

![Enrollment by Grade Level](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/grade-distribution-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#grade-level-distribution)

---

### 12. Honolulu lost 14,170 students while neighbor islands lost only 3,399

Honolulu County (Oahu) has about two-thirds of all students, but neighbor island counties have maintained enrollment more effectively during the statewide decline.

```r
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
```

![Honolulu vs Neighbor Islands](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/honolulu-vs-neighbor-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#honolulu-lost-14170-students-while-neighbor-islands-lost-only-3399)

---

### 13. Elementary schools losing students faster than high schools

Elementary grades (K-5) have seen steeper enrollment declines than secondary grades (6-12), reflecting declining birth rates over the past decade.

```r
level_comparison <- enr %>%
  filter(type == "STATE", !grade_level %in% c("TOTAL", "SPED", "PK")) %>%
  mutate(level = case_when(
    grade_level %in% c("K", "01", "02", "03", "04", "05") ~ "Elementary (K-5)",
    grade_level %in% c("06", "07", "08") ~ "Middle (6-8)",
    TRUE ~ "High School (9-12)"
  )) %>%
  group_by(end_year, level) %>%
  summarize(n_students = sum(n_students, na.rm = TRUE), .groups = "drop")

stopifnot(nrow(level_comparison) > 0)
print(level_comparison)
#> # A tibble: 30 x 3
#>    end_year level              n_students
#>       <dbl> <chr>                   <dbl>
#>  1     2016 Elementary (K-5)        81797
#>  2     2016 High School (9-12)      44468
#>  3     2016 Middle (6-8)            36729
#>  4     2017 Elementary (K-5)        81059
#>  5     2017 High School (9-12)      44509
#>  6     2017 Middle (6-8)            36885
#>  7     2018 Elementary (K-5)        79886
#>  8     2018 High School (9-12)      44830
#>  9     2018 Middle (6-8)            37260
#> 10     2019 Elementary (K-5)        78944
#> # ... 20 more rows
```

![Enrollment by School Level](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/elementary-vs-secondary-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#elementary-schools-losing-students-faster-than-high-schools)

---

### 14. Pre-K enrollment holds steady around 1,600

Pre-Kindergarten enrollment has remained relatively stable around 1,600 students, fluctuating between 1,575 and 1,757 over the past decade.

```r
prek_trend <- enr %>%
  filter(type == "STATE", grade_level == "PK")

stopifnot(nrow(prek_trend) > 0)
print(prek_trend)
#>     end_year district_id                  district_name county_name  type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter
#> 2       2016          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1586  NA            state     TRUE     FALSE      FALSE
#> 98      2017          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1648  NA            state     TRUE     FALSE      FALSE
#> 194     2018          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1582  NA            state     TRUE     FALSE      FALSE
#> 290     2019          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1580  NA            state     TRUE     FALSE      FALSE
#> 386     2020          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1757  NA            state     TRUE     FALSE      FALSE
#> 482     2021          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1737  NA            state     TRUE     FALSE      FALSE
#> 578     2022          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1578  NA            state     TRUE     FALSE      FALSE
#> 674     2023          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1575  NA            state     TRUE     FALSE      FALSE
#> 770     2024          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1659  NA            state     TRUE     FALSE      FALSE
#> 860     2025          HI Hawaii Department of Education State Total STATE          PK total_enrollment       1736  NA            state     TRUE     FALSE      FALSE
```

![Pre-Kindergarten Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/prek-trends-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#pre-k-enrollment-holds-steady-around-1600)

---

### 15. Big Island holds largest neighbor island enrollment

Hawaii County (Big Island) has the largest student population outside Oahu with 22,715 students, serving rural communities across a geographic area larger than all other Hawaiian islands combined.

```r
neighbor_comparison <- enr_current %>%
  filter(grade_level == "TOTAL", type == "COUNTY", county_name != "Honolulu") %>%
  mutate(county_label = reorder(county_name, -n_students))

stopifnot(nrow(neighbor_comparison) > 0)
print(neighbor_comparison)
#>    end_year district_id                  district_name   county_name   type grade_level         subgroup n_students pct aggregation_flag is_state is_county is_charter
#> 35     2025          HI Hawaii Department of Education Hawaii County COUNTY       TOTAL total_enrollment      22715  NA         district    FALSE      TRUE      FALSE
#> 52     2025          HI Hawaii Department of Education          Maui COUNTY       TOTAL total_enrollment      18734  NA         district    FALSE      TRUE      FALSE
#> 69     2025          HI Hawaii Department of Education         Kauai COUNTY       TOTAL total_enrollment       8548  NA         district    FALSE      TRUE      FALSE
```

![Neighbor Island Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/big-island-n_students-1.png)

[(source)](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html#big-island-holds-largest-neighbor-island-enrollment)

---
