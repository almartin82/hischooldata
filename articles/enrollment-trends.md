# Hawaii Enrollment Trends

``` r
library(hischooldata)
library(ggplot2)
library(dplyr)
library(scales)
```

``` r
theme_readme <- function() {
  theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

colors <- c("total" = "#2C3E50", "white" = "#3498DB", "black" = "#E74C3C",
            "hispanic" = "#F39C12", "asian" = "#9B59B6", "hawaiian" = "#1ABC9C")
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
enr <- fetch_enr_multi(year_range)
enr_current <- fetch_enr(max_year)
```

## 1. Hawaii is America’s only statewide school district

Unlike every other state, Hawaii operates as a single statewide school
district with approximately 290 schools. No local school boards, no
property tax funding. One state, one system.

``` r
statewide <- enr_current %>%
  filter(agg_level == "STATE", grade == "TOTAL") %>%
  select(enrollment)

# Count counties (Hawaii is organized by county, not individual schools in this data)
n_counties <- enr_current %>%
  filter(agg_level == "COUNTY", grade == "TOTAL") %>%
  nrow()

cat("Total students:", format(statewide$enrollment, big.mark = ","), "\n")
#> Total students: 167,076
cat("Counties served:", n_counties, "(plus Charter Schools)\n")
#> Counties served: 4 (plus Charter Schools)
```

## 2. Enrollment has been declining for a decade

Hawaii lost 15,000 students since 2015. High housing costs push families
to the mainland, and birth rates are falling.

``` r
state_trend <- enr %>%
  filter(agg_level == "STATE", grade == "TOTAL")

ggplot(state_trend, aes(x = end_year, y = enrollment)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Hawaii Public School Enrollment",
       subtitle = "Declining as families move to the mainland",
       x = "School Year", y = "Students") +
  theme_readme()
```

![](enrollment-trends_files/figure-html/enrollment-decline-1.png)

## 3. Enrollment by County

Hawaii’s single statewide district serves four counties plus charter
schools. Honolulu (Oahu) dominates enrollment, with about two-thirds of
all students.

``` r
county_enr <- enr_current %>%
  filter(grade == "TOTAL", agg_level %in% c("COUNTY", "CHARTER")) %>%
  mutate(county_label = reorder(county_name, -enrollment))

ggplot(county_enr, aes(x = county_label, y = enrollment)) +
  geom_col(fill = colors["total"]) +
  scale_y_continuous(labels = comma) +
  labs(title = "Hawaii Enrollment by County",
       subtitle = "Honolulu dominates with two-thirds of students",
       x = "", y = "Students") +
  theme_readme() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

![](enrollment-trends_files/figure-html/county-distribution-1.png)

## 4. COVID hit enrollment hard

When the pandemic struck, families moved to the mainland or shifted to
private schools. Hawaii saw significant enrollment drops across all
counties.

``` r
# Show year-over-year change during COVID
covid_change <- enr %>%
  filter(end_year %in% c(2020, 2021), grade == "TOTAL", agg_level == "STATE") %>%
  select(end_year, enrollment)

if (nrow(covid_change) == 2) {
  change <- diff(covid_change$enrollment)
  pct_change <- change / covid_change$enrollment[1] * 100
  cat("Enrollment change 2020-2021:", format(change, big.mark = ","),
      sprintf("(%.1f%%)", pct_change), "\n")
}
#> Enrollment change 2020-2021: -4,647 (-2.6%)
```

## 5. Kindergarten is shrinking faster than high school

Hawaii’s kindergarten enrollment has dropped over the years. The
pipeline of students entering the system is narrowing.

``` r
k_trend <- enr %>%
  filter(agg_level == "STATE", grade %in% c("K", "09", "12")) %>%
  mutate(grade_label = case_when(
    grade == "K" ~ "Kindergarten",
    grade == "09" ~ "Grade 9",
    grade == "12" ~ "Grade 12"
  ))

ggplot(k_trend, aes(x = end_year, y = enrollment, color = grade_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "Kindergarten Shrinking Faster Than High School",
       subtitle = "The pipeline of students is narrowing",
       x = "School Year", y = "Students", color = "") +
  theme_readme()
```

![](enrollment-trends_files/figure-html/k-vs-12-1.png)

## 6. Private school competition is fierce

Hawaii has one of the highest private school enrollment rates in the
nation. Kamehameha Schools, Punahou, and Iolani draw thousands of
students who might otherwise attend public schools.

``` r
# Public enrollment as context
public_total <- enr_current %>%
  filter(agg_level == "STATE", grade == "TOTAL") %>%
  pull(enrollment)

cat("Public school enrollment:", format(public_total, big.mark = ","), "\n")
#> Public school enrollment: 167,076
cat("Estimated private school students: ~35,000\n")
#> Estimated private school students: ~35,000
cat("Private school share: ~",
    round(35000 / (public_total + 35000) * 100, 1), "%\n", sep = "")
#> Private school share: ~17.3%
```

## 7. Charter schools are growing

Hawaii’s charter school enrollment has been increasing as an alternative
to traditional public schools managed by the statewide district.

``` r
charter_trend <- enr %>%
  filter(agg_level == "CHARTER", grade == "TOTAL")

ggplot(charter_trend, aes(x = end_year, y = enrollment)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Charter School Enrollment",
       subtitle = "Growing alternative to traditional public schools",
       x = "School Year", y = "Students") +
  theme_readme()
```

![](enrollment-trends_files/figure-html/charter-growth-1.png)

## 8. County trends over time

Each county shows its own enrollment trend. Honolulu (Oahu) dominates
overall enrollment but has seen the largest absolute decline.

``` r
county_trend <- enr %>%
  filter(grade == "TOTAL", agg_level == "COUNTY")

ggplot(county_trend, aes(x = end_year, y = enrollment, color = county_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "Enrollment by County",
       subtitle = "Honolulu dominates but all counties affected by decline",
       x = "School Year", y = "Students", color = "") +
  theme_readme()
```

![](enrollment-trends_files/figure-html/county-trends-1.png)

## 9. Special education enrollment

Hawaii tracks special education enrollment separately from regular
grades in the DBEDT data.

``` r
sped <- enr_current %>%
  filter(agg_level == "STATE", grade == "SPED")

if (nrow(sped) > 0) {
  total <- enr_current %>%
    filter(agg_level == "STATE", grade == "TOTAL") %>%
    pull(enrollment)
  cat("Special education students:", format(sped$enrollment, big.mark = ","), "\n")
  cat("Percent of total enrollment:", sprintf("%.1f%%", sped$enrollment / total * 100), "\n")
} else {
  cat("Special education data not separately reported for this year.\n")
}
#> Special education data not separately reported for this year.
```

## 10. Grade level distribution

Hawaii’s enrollment by grade shows the typical K-12 distribution, with
kindergarten serving as the entry point to the system.

``` r
grade_dist <- enr_current %>%
  filter(agg_level == "STATE", !grade %in% c("TOTAL", "SPED")) %>%
  mutate(grade = factor(grade, levels = c("PK", "K", sprintf("%02d", 1:12))))

ggplot(grade_dist, aes(x = grade, y = enrollment)) +
  geom_col(fill = colors["total"]) +
  scale_y_continuous(labels = comma) +
  labs(title = "Enrollment by Grade Level",
       subtitle = paste("Hawaii Public Schools,", max_year),
       x = "Grade", y = "Students") +
  theme_readme()
```

![](enrollment-trends_files/figure-html/grade-distribution-1.png)
