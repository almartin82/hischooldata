# hischooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/hischooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/hischooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/hischooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/hischooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/hischooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/hischooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**[Documentation](https://almartin82.github.io/hischooldata/)** | **[Getting Started](https://almartin82.github.io/hischooldata/articles/hischooldata.html)** | **[Enrollment Trends](https://almartin82.github.io/hischooldata/articles/enrollment-trends.html)**

Fetch and analyze Hawaii school enrollment data from the Hawaii Department of Education (HIDOE) in R or Python.

## Why hischooldata?

This package is part of the [State Schooldata Project](https://github.com/almartin82/njschooldata), which started with [njschooldata](https://github.com/almartin82/njschooldata) for New Jersey. The goal is to provide a simple, consistent interface for accessing state-published school data directly from state Departments of Education - not federal aggregations that lose state-specific details.

Hawaii is unique: it's America's only statewide school district. One state, one system, no local school boards. This package lets you explore 15+ years of enrollment data across counties and schools with a single function call.

## What can you find with hischooldata?

**15 years of enrollment data (2010-2025).** ~167,000 students in 2025. Here are 15 stories hiding in the numbers:

---

### 1. Hawaii is America's only statewide school district

Unlike every other state, Hawaii operates as a single statewide school district with approximately 290 schools. No local school boards, no property tax funding. One state, one system.

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

statewide <- enr_current %>%
  filter(type == "STATE", grade_level == "TOTAL") %>%
  select(n_students)

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

### 2. Enrollment has been declining for a decade

Hawaii lost 15,000 students since 2015. High housing costs push families to the mainland, and birth rates are falling.

```r
state_trend <- enr %>%
  filter(type == "STATE", grade_level == "TOTAL")

stopifnot(nrow(state_trend) > 0)
state_trend

ggplot(state_trend, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = "#2C3E50") +
  geom_point(size = 3, color = "#2C3E50") +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Hawaii Public School Enrollment",
       subtitle = "Declining as families move to the mainland",
       x = "School Year", y = "Students") +
  theme_minimal(base_size = 14)
```

![Hawaii Public School Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/n_students-decline-1.png)

---

### 3. Enrollment by County

Hawaii's single statewide district serves four counties plus charter schools. Honolulu (Oahu) dominates enrollment, with about two-thirds of all students.

```r
county_enr <- enr_current %>%
  filter(grade_level == "TOTAL", type %in% c("COUNTY", "CHARTER")) %>%
  mutate(county_label = reorder(county_name, -n_students))

stopifnot(nrow(county_enr) > 0)
county_enr

ggplot(county_enr, aes(x = county_label, y = n_students)) +
  geom_col(fill = "#2C3E50") +
  scale_y_continuous(labels = comma) +
  labs(title = "Hawaii Enrollment by County",
       subtitle = "Honolulu dominates with two-thirds of students",
       x = "", y = "Students") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

![Hawaii Enrollment by County](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/county-distribution-1.png)

---

### 4. COVID hit enrollment hard

When the pandemic struck, families moved to the mainland or shifted to private schools. Hawaii saw significant enrollment drops across all counties.

```r
# Show year-over-year change during COVID
covid_change <- enr %>%
  filter(end_year %in% c(2020, 2021), grade_level == "TOTAL", type == "STATE") %>%
  select(end_year, n_students)

if (nrow(covid_change) == 2) {
  change <- diff(covid_change$n_students)
  pct_change <- change / covid_change$n_students[1] * 100
  cat("Enrollment change 2020-2021:", format(change, big.mark = ","),
      sprintf("(%.1f%%)", pct_change), "\n")
}
#> Enrollment change 2020-2021: -4,647 (-2.6%)
```

---

### 5. Kindergarten is shrinking faster than high school

Hawaii's kindergarten enrollment has dropped over the years. The pipeline of students entering the system is narrowing.

```r
k_trend <- enr %>%
  filter(type == "STATE", grade_level %in% c("K", "09", "12")) %>%
  mutate(grade_label = case_when(
    grade_level == "K" ~ "Kindergarten",
    grade_level == "09" ~ "Grade 9",
    grade_level == "12" ~ "Grade 12"
  ))

stopifnot(nrow(k_trend) > 0)
k_trend

ggplot(k_trend, aes(x = end_year, y = n_students, color = grade_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "Kindergarten Shrinking Faster Than High School",
       subtitle = "The pipeline of students is narrowing",
       x = "School Year", y = "Students", color = "") +
  theme_minimal(base_size = 14)
```

![Kindergarten vs High School](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/k-vs-12-1.png)

---

### 6. Private school competition is fierce

Hawaii has one of the highest private school enrollment rates in the nation. Kamehameha Schools, Punahou, and Iolani draw thousands of students who might otherwise attend public schools.

```r
# Public enrollment as context
public_total <- enr_current %>%
  filter(type == "STATE", grade_level == "TOTAL") %>%
  pull(n_students)

cat("Public school enrollment:", format(public_total, big.mark = ","), "\n")
cat("Estimated private school students: ~35,000\n")
cat("Private school share: ~",
    round(35000 / (public_total + 35000) * 100, 1), "%\n", sep = "")
#> Public school enrollment: 167,076
#> Estimated private school students: ~35,000
#> Private school share: ~17.3%
```

---

### 7. Charter schools are growing

Hawaii's charter school enrollment has been increasing as an alternative to traditional public schools managed by the statewide district.

```r
charter_trend <- enr %>%
  filter(type == "CHARTER", grade_level == "TOTAL")

stopifnot(nrow(charter_trend) > 0)
charter_trend

ggplot(charter_trend, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = "#2C3E50") +
  geom_point(size = 3, color = "#2C3E50") +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Charter School Enrollment",
       subtitle = "Growing alternative to traditional public schools",
       x = "School Year", y = "Students") +
  theme_minimal(base_size = 14)
```

![Charter School Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/charter-growth-1.png)

---

### 8. County trends over time

Each county shows its own enrollment trend. Honolulu (Oahu) dominates overall enrollment but has seen the largest absolute decline.

```r
county_trend <- enr %>%
  filter(grade_level == "TOTAL", type == "COUNTY")

stopifnot(nrow(county_trend) > 0)
county_trend

ggplot(county_trend, aes(x = end_year, y = n_students, color = county_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "Enrollment by County",
       subtitle = "Honolulu dominates but all counties affected by decline",
       x = "School Year", y = "Students", color = "") +
  theme_minimal(base_size = 14)
```

![Enrollment by County Over Time](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/county-trends-1.png)

---

### 9. Special education enrollment

Hawaii tracks special education enrollment separately from regular grades in the DBEDT data.

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
```

---

### 10. Grade level distribution

Hawaii's enrollment by grade shows the typical K-12 distribution, with kindergarten serving as the entry point to the system.

```r
grade_dist <- enr_current %>%
  filter(type == "STATE", !grade_level %in% c("TOTAL", "SPED")) %>%
  mutate(grade_level = factor(grade_level, levels = c("PK", "K", sprintf("%02d", 1:12))))

stopifnot(nrow(grade_dist) > 0)
grade_dist

ggplot(grade_dist, aes(x = grade_level, y = n_students)) +
  geom_col(fill = "#2C3E50") +
  scale_y_continuous(labels = comma) +
  labs(title = "Enrollment by Grade Level",
       subtitle = paste("Hawaii Public Schools,", max_year),
       x = "Grade", y = "Students") +
  theme_minimal(base_size = 14)
```

![Enrollment by Grade Level](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/grade-distribution-1.png)

---

### 11. Honolulu dominates but neighbor islands hold stronger

Honolulu County (Oahu) has about two-thirds of all students, but neighbor island counties have maintained enrollment more effectively during the statewide decline.

```r
island_comparison <- enr %>%
  filter(grade_level == "TOTAL", type == "COUNTY") %>%
  mutate(island_group = ifelse(county_name == "Honolulu", "Honolulu (Oahu)", "Neighbor Islands")) %>%
  group_by(end_year, island_group) %>%
  summarize(n_students = sum(n_students, na.rm = TRUE), .groups = "drop")

stopifnot(nrow(island_comparison) > 0)
island_comparison

ggplot(island_comparison, aes(x = end_year, y = n_students, color = island_group)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 3) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  scale_color_manual(values = c("Honolulu (Oahu)" = "#2C3E50", "Neighbor Islands" = "#1ABC9C")) +
  labs(title = "Honolulu vs Neighbor Islands",
       subtitle = "Oahu dominates but faces steeper decline",
       x = "School Year", y = "Students", color = "") +
  theme_minimal(base_size = 14)
```

![Honolulu vs Neighbor Islands](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/honolulu-vs-neighbor-1.png)

---

### 12. Elementary schools losing students faster than high schools

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
level_comparison

ggplot(level_comparison, aes(x = end_year, y = n_students, color = level)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  scale_color_manual(values = c(
    "Elementary (K-5)" = "#3498DB",
    "Middle (6-8)" = "#F39C12",
    "High School (9-12)" = "#E74C3C"
  )) +
  labs(title = "Enrollment by School Level",
       subtitle = "Elementary schools losing students faster than high schools",
       x = "School Year", y = "Students", color = "") +
  theme_minimal(base_size = 14)
```

![Enrollment by School Level](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/elementary-vs-secondary-1.png)

---

### 13. Maui's tourism economy shows in school enrollment

Maui County has seen enrollment fluctuations tied to its tourism-dependent economy. The 2023 wildfires added new challenges to an already changing population.

```r
maui_trend <- enr %>%
  filter(grade_level == "TOTAL", county_name == "Maui")

stopifnot(nrow(maui_trend) > 0)
maui_trend

ggplot(maui_trend, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = "#9B59B6") +
  geom_point(size = 3, color = "#9B59B6") +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Maui County Enrollment",
       subtitle = "Tourism economy and population shifts affect enrollment",
       x = "School Year", y = "Students") +
  theme_minimal(base_size = 14)
```

![Maui County Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/maui-n_students-1.png)

---

### 14. Pre-K enrollment signals future trends

Pre-Kindergarten enrollment provides an early signal of what elementary schools will see in coming years. Hawaii's Pre-K numbers show the declining pipeline.

```r
prek_trend <- enr %>%
  filter(type == "STATE", grade_level == "PK")

if (nrow(prek_trend) > 0 && sum(prek_trend$n_students, na.rm = TRUE) > 0) {
  prek_trend

  ggplot(prek_trend, aes(x = end_year, y = n_students)) +
    geom_line(linewidth = 1.5, color = "#1ABC9C") +
    geom_point(size = 3, color = "#1ABC9C") +
    scale_y_continuous(labels = comma, limits = c(0, NA)) +
    labs(title = "Pre-Kindergarten Enrollment",
         subtitle = "Early indicator of future elementary enrollment",
         x = "School Year", y = "Students") +
    theme_minimal(base_size = 14)
} else {
  cat("Pre-K data not available or all zeros in the data range.\n")
}
```

![Pre-Kindergarten Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/prek-trends-1.png)

---

### 15. Big Island holds largest neighbor island enrollment

Hawaii County (Big Island) has the largest student population outside Oahu, serving rural communities across a geographic area larger than all other Hawaiian islands combined.

```r
neighbor_comparison <- enr_current %>%
  filter(grade_level == "TOTAL", type == "COUNTY", county_name != "Honolulu") %>%
  mutate(county_label = reorder(county_name, -n_students))

stopifnot(nrow(neighbor_comparison) > 0)
neighbor_comparison

ggplot(neighbor_comparison, aes(x = county_label, y = n_students)) +
  geom_col(fill = "#E74C3C") +
  geom_text(aes(label = comma(n_students)), vjust = -0.5, size = 4) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Neighbor Island Enrollment",
       subtitle = "Hawaii County (Big Island) leads outside Oahu",
       x = "", y = "Students") +
  theme_minimal(base_size = 14)
```

![Neighbor Island Enrollment](https://almartin82.github.io/hischooldata/articles/enrollment-trends_files/figure-html/big-island-n_students-1.png)

---

## Installation

### R

```r
# install.packages("remotes")
remotes::install_github("almartin82/hischooldata")
```

### Python

```bash
pip install git+https://github.com/almartin82/hischooldata.git#subdirectory=pyhischooldata
```

## Quick Start

### R

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

## Data Notes

### Data Source

Hawaii Department of Education via the [DBEDT State Data Book](https://files.hawaii.gov/dbedt/economic/databook/) (Tables 3.12 and 3.13).

### Available Years

- **2010-2025** (end_year convention: 2024 = 2023-24 school year)
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

## Data Availability

| Years | Source | Aggregation Levels | Notes |
|-------|--------|-------------------|-------|
| **2018-2025** | HIDOE Official Enrollment | State, County, Charter | Modern Excel format |
| **2010-2017** | DBEDT State Data Book | State, County | Aggregate data from Data Book |

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data in Python and R. This package is part of the [State Schooldata Project](https://github.com/almartin82/njschooldata), which started with [njschooldata](https://github.com/almartin82/njschooldata) for New Jersey.

**All 50 state packages:** [github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (almartin@gmail.com)

## License

MIT
