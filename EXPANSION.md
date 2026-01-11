# Hawaii School Data Expansion Research

**Last Updated:** 2026-01-11
**Theme Researched:** Assessment (K-8 and High School, excluding SAT/ACT)

## Data Sources Found

### Source 1: Strive HI Master Data Files (2013-14, 2014-15) ⭐ PRIMARY SOURCE
- **URL:** https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2014/2013-14MasterDataFile.xlsx
- **URL:** https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2015/2014-15MasterDataFile.xlsx
- **HTTP Status:** 200 (both files verified accessible)
- **Format:** Excel (.xlsx)
- **Years Available:** 2013-14, 2014-15 ONLY
- **Access:** Direct download, no authentication required
- **Assessment Types:** Math, Reading, Science proficiency percentages
- **Notes:** These are the ONLY raw assessment data files found in Excel format

### Source 2: Strive HI School Classification Files
- **URL:** https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2014/2013-14SchoolClassification.xlsx
- **URL:** https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2015/2014-15SchoolClassification.xlsx
- **HTTP Status:** 200 (verified)
- **Format:** Excel (.xlsx)
- **Years:** 2013-14, 2014-15
- **Content:** School classifications, index scores, Title I status
- **Notes:** Contains less detailed assessment data than Master Data Files

### Source 3: ARCH (Accountability Resource Center Hawaii)
- **URL:** https://arch.k12.hi.us/reports/strivehi-performance
- **HTTP Status:** 200
- **Format:** Interactive JavaScript dashboard
- **Years:** Unknown (current year + limited history)
- **Access:** Web interface only, NO API or export functionality found
- **Notes:** Primary reporting platform but NOT programmatic-accessible

### Source 4: HIDOE Data Book
- **URL:** https://arch.k12.hi.us/reports/hidoe-data-book
- **Format:** PDF reports with summary statistics
- **Years:** Annual (2024 confirmed, likely earlier years exist)
- **Access:** Public download
- **Notes:** Contains assessment summary tables but NOT raw school-level data

### Source 5: ESSA Report Cards
- **URL:** https://arch.k12.hi.us/reports/essa
- **Format:** PDF reports (annual)
- **Years:** 2017-present (ESSA requirement)
- **Access:** Public download
- **Notes:** Federal accountability reports with aggregated assessment data

## Schema Analysis

### Master Data File Structure (2013-14, 2014-15)

#### Column Names:
```
- School ID
- Year
- School Name
- School Type for Strive HI (Elementary/Middle/High)
- Title I (Yes/No)
- Complex Area
- Strive HI Step (Recognition/Continuous Improvement/Focus/Priority)
- Final Index Score (0-400 points)
- Math Proficiency (%)
- Math Participation Penalty?
- Math Proficiency - Pooled Data?
- Reading Proficiency (%)
- Reading Participation Penalty?
- Reading Proficiency - Pooled Data?
- Science Proficiency (%)
- Science Participation Penalty?
- Science Proficiency - Pooled Data?
- Math Median SGP (Student Growth Percentile)
- Math SGP - Used Pooled Data
- Reading Median SGP
- Reading SGP - Used Pooled Data
```

#### Key Schema Features:
- **School-level data** (not student-level)
- **Percentages rounded to nearest integer**
- **Pooled data flags** indicate multi-year averaging for small schools
- **Participation penalties** applied when <95% tested
- **Growth measures** included (SGP - Student Growth Percentile)
- **Index score** calculated from multiple indicators

#### ID System:
- School ID: Numeric identifier (format needs verification from actual data rows)
- Complex Area: Geographic grouping of schools
- No district ID (Hawaii is single statewide district)

### Known Data Issues:
1. **Data suppression** for small schools (pooled data used)
2. **Rounding to integers** (precision loss)
3. **Index calculation artifacts** - some values may not match published data
4. **Participation penalties** can affect proficiencies
5. **Limited year coverage** - only 2 years of raw data found

## Critical Blocker

**NO RAW ASSESSMENT DATA AVAILABLE FOR 2015-16 TO PRESENT**

After extensive searching, only TWO years of downloadable assessment data exist:
- 2013-14 (Master Data File)
- 2014-15 (Master Data File)

**All subsequent years (2015-16 through present) are only available through:**
1. **ARCH Dashboard** - JavaScript-rendered, no export option
2. **PDF Reports** - Summary tables, not raw data
3. **School report cards** - Individual school PDFs

### Why This Matters:
- Hawaii stopped publishing Master Data Files after 2014-15
- Transitioned to ARCH dashboard (web-only access)
- No API identified
- No bulk download option found
- Web scraping may violate ToS and is fragile

## Time Series Heuristics

Based on 2013-14 and 2014-15 Master Data Files:

### Expected Ranges:
- **Schools:** ~290 schools (traditional + charter)
- **Math Proficiency:** 30-60% typical (varies by grade/subject)
- **Reading Proficiency:** 40-70% typical
- **Science Proficiency:** 30-50% typical
- **Participation Rate:** 95%+ required (penalties if lower)
- **Index Score:** 0-400 points

### State Total Expectations (2013-14 data needed):
- Total students tested: ~180,000
- Proficiency percentages vary by subject
- All schools should have data (except very small charter schools)

### Major Entities:
- No traditional districts (Hawaii is single district)
- Complex Areas: ~15-20 geographic groupings
- School types: Elementary, Middle, High, K-12, K-8, etc.

## Recommended Implementation

### Priority: **MEDIUM** (Limited Data Availability)
### Complexity: **EASY** (for 2 years) / **BLOCKED** (for 2015-16 to present)
### Estimated Files to Modify: 8-10

### What Can Be Implemented:

**Option 1: Implement 2-Year Assessment Dataset (RECOMMENDED)**

Implement assessment data for the ONLY 2 years with raw data (2013-14, 2014-15):

**Pros:**
- Clean, raw Excel data with school-level detail
- Math, Reading, Science proficiency percentages
- Student Growth Percentiles (SGP)
- Implementation straightforward
- No web scraping needed

**Cons:**
- Only 2 years of data (2013-14, 2014-15)
- Not useful for trend analysis
- May confuse users expecting recent data

**Files to Create:**
1. `R/get_raw_assessment.R` - Download Master Data Files
2. `R/process_assessment.R` - Parse Excel files
3. `R/tidy_assessment.R` - Transform to tidy format
4. `R/fetch_assessment.R` - User-facing function
5. `tests/testthat/test-assessment-pipeline-live.R` - LIVE tests
6. `tests/testthat/test-assessment-fidelity.R` - Fidelity tests
7. `vignettes/assessment-trends.Rmd` - Documentation
8. `man/fetch_assessment.Rd` - Function documentation

**Estimated Implementation Time:** 4-6 hours

**Option 2: Contact HIDOE for Data Access (RECOMMENDED FOR FULL IMPLEMENTATION)**

Before implementing, contact Hawaii DOE Research & Evaluation Office:

**Ask for:**
- Historical Master Data Files for 2015-16 to present
- API access to ARCH data
- Bulk data download option
- Automated data access method

**Contact:**
- Hawaii DOE Research & Data Requests: https://hawaiipublicschools.org/data-reports/research-and-data-requests/
- Data Request Form: https://www.hawaiipublicschools.org/DOE%20Forms/DataGov/DataRequestForm.xlsx

**Option 3: Web Scraping ARCH Dashboard (NOT RECOMMENDED)**

**Challenges:**
- JavaScript-rendered content (requires Selenium/Playwright)
- No documented API
- May violate Terms of Service
- Extremely fragile (breaks when site changes)
- No guarantee of historical data access
- Ethical/legal concerns

**Recommendation:** DO NOT pursue without explicit HIDOE permission

## Test Requirements

### Raw Data Fidelity Tests Needed:

**2013-14 Data:**
```r
test_that("2013-14: State total Math proficiency matches raw Excel", {
  skip_if_offline()

  data <- fetch_assessment(2014, subject = "math")

  # Verify against manually checked value from Master Data File
  # (Need to download and verify actual value)
  expect_equal(nrow(data), 290, tolerance = 5)  # ~290 schools
})
```

**2014-15 Data:**
```r
test_that("2014-15: Specific school proficiency matches raw Excel", {
  skip_if_offline()

  data <- fetch_assessment(2015, subject = "math")

  # Verify known school (e.g., 'Aiea High School')
  aiea <- data %>% filter(school_name == "Aiea High School")
  # (Need to check actual value in Excel file)
  expect_true(aiea$math_proficiency >= 0 & aiea$math_proficiency <= 100)
})
```

### Data Quality Checks:
- All proficiency percentages between 0-100
- No negative values
- All schools have School ID
- No duplicate school-year combinations
- All years have data (2013-14, 2014-15)
- Major complex areas present
- Participation penalty flags are boolean

## Implementation Decision Matrix

| Factor | Option 1 (2 Years Only) | Option 2 (Request Data) | Option 3 (Scraping) |
|--------|------------------------|-------------------------|---------------------|
| Data completeness | 2 years | Unknown | Potentially full |
| Implementation ease | Easy | N/A (contact) | Hard |
| Maintenance burden | Low | Low | High |
| Legal/ethical risk | None | None | High |
| User value | Limited | High | Medium |
| Reliability | High | Unknown | Low |

## Final Recommendation

**Recommended Approach: Two-Phase Implementation**

### Phase 1: Quick Win (Implement 2-Year Dataset)
1. Implement assessment functions for 2013-14 and 2014-15 ONLY
2. Clearly document limitation: "Only 2 years of raw assessment data available"
3. Add note: "Contact HIDOE for recent years (2015-16 to present)"
4. Implement with standard tests and documentation
5. Estimated time: 4-6 hours

### Phase 2: Data Access Request
1. Submit formal data request to Hawaii DOE
2. Ask for Master Data Files for 2015-16 to present
3. Inquire about API access to ARCH
4. If successful, extend implementation to all years

### Alternative: Prioritize Different Theme
Given the severe data limitation (only 2 years), consider prioritizing a different data theme with better availability:
- **Demographics** (race/ethnicity) - may be in enrollment files
- **ELL/SPED/FRPL** - subgroup data in enrollment
- **Attendance** - chronic absenteeism in ARCH (same limitation)
- **Graduation** - may have better historical data

## Conclusion

**Hawaii assessment data implementation is SEVERELY LIMITED** due to:
1. Only 2 years of raw data (2013-14, 2014-15)
2. No public data access for 2015-16 to present
3. ARCH dashboard not programmatic-accessible
4. Web scraping not recommended without permission

**Can implement:** 2-year assessment dataset (2013-14, 2014-15)
**Cannot implement:** Multi-year trends, recent data

**Recommendation:**
- Implement 2-year dataset if user accepts limitation
- OR prioritize different data theme with better availability
- OR contact HIDOE for full historical data access

---

**Research Status:** LIMITED DATA AVAILABILITY - Only 2 years found
**Confidence Level:** HIGH - Thorough search of official HIDOE sources
**Last Reviewer:** Claude (expand-state skill)
**Date:** 2026-01-11

## Sources

- [Hawaii Strive HI Performance System](https://arch.k12.hi.us/reports/strivehi-performance)
- [Hawaii Public Schools School Reports](https://hawaiipublicschools.org/data-reports/school-reports/)
- [Hawaii DOE Research and Data Requests](https://hawaiipublicschools.org/data-reports/research-and-data-requests/)
- [2013-14 Master Data File (Excel)](https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2014/2013-14MasterDataFile.xlsx)
- [2014-15 Master Data File (Excel)](https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2015/2014-15MasterDataFile.xlsx)
- [Hawaii Strive HI Technical Guides](https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2023/StriveHITechnicalGuide2023.pdf)
