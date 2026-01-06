# Hawaii School Data Expansion Research

**Last Updated:** 2026-01-04 **Theme Researched:** Graduation Rates

## Current Package Status

- **R-CMD-check:** Passing
- **Python tests:** Passing
- **pkgdown:** Passing

## Current Package Capabilities

The `hischooldata` package currently supports: - **Enrollment data
only** via
[`fetch_enr()`](https://almartin82.github.io/hischooldata/reference/fetch_enr.md)
and
[`fetch_enr_multi()`](https://almartin82.github.io/hischooldata/reference/fetch_enr_multi.md) -
**Years:** 2011-2025 (2012 not available - no 2011 Data Book) - **Data
sources:** DBEDT State Data Book, HIDOE official enrollment files -
**Aggregation levels:** State total, County (Honolulu, Hawaii County,
Maui, Kauai), Charter Schools

**No graduation rate functions currently exist.**

------------------------------------------------------------------------

## Data Sources Found

### Source 1: Hawaii P-20 CCRI (College and Career Readiness Indicators)

**PRIMARY RECOMMENDED SOURCE**

- **URL:**
  <https://www.hawaiidxp.org/wp-content/uploads/2025/03/CCRI_Data_2020-2021-2022-2023-2024-Public_Final.xlsx>
- **HTTP Status:** 200 OK
- **Format:** Excel (.xlsx)
- **Years Available:** 2020-2024 (Class of)
- **Access Method:** Direct download
- **Update Frequency:** Annual (March release)
- **Data Level:** School-level

**Key Fields:** \| Field \| Description \| \|——-\|————-\| \| GradYr \|
Graduation year (2020-2024) \| \| SchCode \| DOE school code (3-digit)
\| \| CCRI_SchoolName \| School name \| \| ComplexArea \| Geographic
cluster (15 complex areas) \| \| Island \| Oahu, Hawaii, Maui, Kauai,
Molokai, Lanai \| \| County \| County name \| \| Completers \| Number of
high school completers \| \| OnTimeGrad \| 4-year Adjusted Cohort
Graduation Rate (ACGR) as decimal (e.g., 0.86) \| \| Honors_Cert_Pct \|
Percent earning honors certificate \| \| NSC_Fall_Pct \| Percent
enrolling in postsecondary \|

**Notes:** - Redacted values marked with `*` when counts \< 10 -
Contains 65-68 schools per year - Does NOT include subgroup breakdowns
(no race, SPED, ELL, FRPL) - Decimal format (0.86 = 86%)

### Source 2: DBEDT State Data Book (Table 3.15)

**SECONDARY SOURCE - Graduation COUNTS (not rates)**

- **URL Pattern:**
  `https://files.hawaii.gov/dbedt/economic/databook/{YEAR}-individual/03/0315{YY}.xls`
- **HTTP Status:** 200 OK for all years except 2011 (404)
- **Format:** Excel (.xls)
- **Years Available:** 1990-2022 (via 2024 Data Book)
- **Access Method:** Direct download
- **Data Level:** State aggregate only

**Available Years (HTTP 200):** \| Data Book Year \| HTTP Status \| URL
\| \|—————-\|————-\|—–\| \| 2010 \| 200 \|
<https://files.hawaii.gov/dbedt/economic/databook/2010-individual/03/031510.xls>
\| \| 2011 \| 404 \| Not available \| \| 2013 \| 200 \|
<https://files.hawaii.gov/dbedt/economic/databook/2013-individual/03/031513.xls>
\| \| 2014-2024 \| 200 \| Pattern: `0315{YY}.xls` \|

**Data Fields:** - Year - Total graduates (public + private) - Public
school graduates - Private school graduates

**Limitations:** - Counts only, not graduation RATES - State-level only
(no school or district breakdown) - No subgroup data

### Source 3: Strive HI State Reports

- **URL:**
  <https://hawaiipublicschools.org/wp-content/uploads/Strive-HI-State-Report-2025.pdf>
- **HTTP Status:** 200 OK
- **Format:** PDF (not machine-readable)
- **Years Available:** 2020-21 through 2024-25
- **Data Level:** State aggregate

**Graduation Rate Data in Strive HI:** \| Class Year \| On-Time Grad
Rate \| \|————\|——————-\| \| 2021 \| 86% \| \| 2022 \| 85% \| \| 2023 \|
86% \| \| 2024 \| 86% \| \| 2025 (prelim) \| 86% \|

**Limitations:** - PDF format - requires manual extraction - State-level
only - No school-level breakdown in PDF

### Source 4: ARCH ADC (Accountability Data Center)

- **URL:** <https://adc.hidoe.us>
- **HTTP Status:** 200 (JavaScript required)
- **Format:** Interactive dashboard
- **Access Method:** Web application (JavaScript required)

**Notes:** - Contains school-level Strive HI data - Graduation rates by
subgroup (race, SPED, ELL, economically disadvantaged) - No direct
downloadable files found - May require API exploration or scraping

### Source 5: LEI Kukui / ESSA Data Portal

- **URL:** <https://hidoedata.org>
- **HTTP Status:** 302 redirect to dashboard
- **Format:** Interactive dashboard
- **Access Method:** Web application (JavaScript required)

**Notes:** - ESSA compliance data reporting - Graduation rates by
subgroup available in dashboard - No bulk download option found

------------------------------------------------------------------------

## Schema Analysis

### CCRI Data Schema (2020-2024)

**Column Names (consistent across all years):**

    GradYr, SchCode, CCRI_SchoolName, ComplexArea, Island, County,
    Completers_Redact, Completers, Honors_Cert_Redact, Honors_Cert_Pct,
    OnTimeGrad_Redact, OnTimeGrad, [86 total columns]

**ID System:** - School Code: 3-digit numeric (e.g., 103, 106, 220) - No
district ID (Hawaii is single statewide district) - Complex Area: Text
string (15 areas)

**Data Quality Notes:** - Redacted cells have `*` in corresponding
`_Redact` column - Graduation rates as decimals (0.00-1.00) - Completers
count includes diploma + Certificate of Completion

### DBEDT Data Schema

**Header Structure:** - Row 1: Table title - Row 2-5: Notes/blank - Row
6: Column headers (Year, Total graduates, Public school graduates,
Private school graduates) - Row 7: Blank - Row 8+: Data rows

**Known Issues:** - Multi-row header requires skip logic - Year column
is text, needs conversion to numeric

------------------------------------------------------------------------

## Time Series Heuristics

### Expected Ranges

| Metric                   | Expected Range  | Red Flag If           |
|--------------------------|-----------------|-----------------------|
| State graduation rate    | 82% - 90%       | Outside this range    |
| YoY change               | \< 3%           | Change \> 5%          |
| Total completers (state) | 10,000 - 13,000 | \< 9,000 or \> 15,000 |
| Schools with data        | 60 - 70         | \< 55                 |

### Verified Values for Fidelity Tests

From CCRI 2020-2024 data: \| School \| Year \| OnTimeGrad \| Completers
\| \|——–\|——\|————\|————\| \| Farrington High School \| 2024 \| 0.73 \|
438 \| \| Kaimuki High School \| 2024 \| 0.79 \| 130 \| \| Kalani High
School \| 2024 \| (verify) \| (verify) \|

From Strive HI: \| Class Year \| State Rate \| \|————\|————\| \| 2024 \|
86% \| \| 2023 \| 86% \| \| 2022 \| 85% \| \| 2021 \| 86% \|

------------------------------------------------------------------------

## Missing Data / Gaps

### What Is Available

- School-level graduation rates (ACGR): 2020-2024 via CCRI
- State-level graduation rates: 2021-2025 via Strive HI
- Graduation counts: 1990-2022 via DBEDT

### What Is NOT Available (Downloadable)

- **Subgroup graduation rates** (race/ethnicity, SPED, ELL, economically
  disadvantaged)
  - Available in ARCH ADC dashboard but not downloadable
  - Would require web scraping or API discovery
- **Years before 2020** for school-level ACGR rates
- **Extended completion rates** (5-year rates) at school level

### Potential Future Sources

- ARCH ADC API (if available)
- HIDOE data request
- Older CCRI files (2015-2019) - URLs appear to be removed/migrated

------------------------------------------------------------------------

## Recommended Implementation

### Priority: **MEDIUM**

### Complexity: **EASY** (for CCRI data)

### Estimated Files to Modify: 3-4

### Implementation Approach

**Phase 1: CCRI-based graduation rates (Recommended)**

Add functions to fetch and process CCRI data:

1.  `get_raw_grad()` - Download CCRI Excel file
2.  `fetch_grad()` - Return school-level graduation data
3.  `fetch_grad_multi()` - Multi-year convenience function

**Proposed Output Schema:**

``` r
tibble(
  end_year = integer(),      # Graduation year
  school_code = character(), # 3-digit school code
  school_name = character(),
  complex_area = character(),
  island = character(),
  county = character(),
  completers = integer(),    # Number of completers
  grad_rate = numeric(),     # On-time graduation rate (decimal)
  honors_pct = numeric()     # Percent with honors (optional)
)
```

**Phase 2: DBEDT graduation counts (Optional)**

Add functions to fetch historical graduate counts:

1.  `get_raw_grad_counts()` - Download DBEDT Table 3.15
2.  `fetch_grad_counts()` - Return state-level graduate counts

------------------------------------------------------------------------

## Test Requirements

### Raw Data Fidelity Tests Needed

``` r
test_that("2024 CCRI: Farrington graduation rate matches raw", {
  skip_if_offline()
  data <- fetch_grad(2024)
  farrington <- data |> filter(school_code == "106")
  expect_equal(farrington$grad_rate, 0.73, tolerance = 0.01)
  expect_equal(farrington$completers, 438)
})

test_that("2024 CCRI: State average is approximately 86%", {
  skip_if_offline()
  data <- fetch_grad(2024)
  weighted_avg <- sum(data$completers * data$grad_rate) / sum(data$completers)
  expect_equal(weighted_avg, 0.86, tolerance = 0.02)
})
```

### Data Quality Checks

``` r
test_that("Graduation rates are valid percentages", {
  data <- fetch_grad(2024)
  expect_true(all(data$grad_rate >= 0 & data$grad_rate <= 1, na.rm = TRUE))
})

test_that("Completers are positive integers", {
  data <- fetch_grad(2024)
  expect_true(all(data$completers > 0, na.rm = TRUE))
})

test_that("All years have 60+ schools", {
  for (yr in 2020:2024) {
    data <- fetch_grad(yr)
    expect_gte(nrow(data), 60, info = paste("Year:", yr))
  }
})
```

------------------------------------------------------------------------

## Implementation Steps

1.  Create `R/get_raw_graduation.R`:

    - `get_ccri_url()` - Generate CCRI download URL
    - `download_ccri_data()` - Download and cache CCRI Excel
    - `get_raw_grad()` - Parse CCRI Excel to data frame

2.  Create `R/fetch_graduation.R`:

    - `fetch_grad()` - Main user-facing function
    - `fetch_grad_multi()` - Multi-year fetch

3.  Create `tests/testthat/test-graduation-live.R`:

    - URL availability tests
    - Download tests
    - Parsing tests
    - Fidelity tests
    - Data quality tests

4.  Update `NAMESPACE` and documentation

5.  Update `DESCRIPTION` (no new dependencies needed)

------------------------------------------------------------------------

## Open Questions

1.  **CCRI file URL stability**: The file is at
    `/wp-content/uploads/2025/03/...` - will this URL change annually?
    - Recommendation: Check for URL pattern or search page for latest
      file
2.  **Subgroup data**: Should we pursue ARCH ADC scraping for subgroup
    graduation rates?
    - This would add significant complexity
3.  **Historical data**: Should we attempt to recover 2015-2019 CCRI
    data?
    - Would require reaching out to Hawaii P-20 or searching archives
4.  **Extended completion**: Should we include 5-year extended
    completion rate?
    - Available in CCRI data but unclear if useful

------------------------------------------------------------------------

## References

- Hawaii DXP CCRI:
  <https://www.hawaiidxp.org/data-products/college-and-career-readiness-indicators/>
- DBEDT Data Book: <https://dbedt.hawaii.gov/economic/databook/>
- Strive HI Dashboard:
  <https://hawaiipublicschools.org/about/organization/strive-hi-dashboard/>
- ARCH ADC: <https://adc.hidoe.us>
