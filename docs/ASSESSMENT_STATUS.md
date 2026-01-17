# Hawaii Assessment Data Status

**Package:** hischooldata **Date:** 2026-01-12 **Status:** NOT
IMPLEMENTED

------------------------------------------------------------------------

## Current Implementation Status

**Assessment data is NOT implemented in this package.**

The package currently only supports enrollment data via: -
[`fetch_enr()`](https://almartin82.github.io/hischooldata/reference/fetch_enr.md) -
Fetch single year enrollment -
[`fetch_enr_multi()`](https://almartin82.github.io/hischooldata/reference/fetch_enr_multi.md) -
Fetch multiple years enrollment

### No Assessment Functions Exist

The following functions do NOT exist in the package: -
`fetch_assessment()` or `fetch_assess()` - `get_raw_assessment()` -
`process_assessment()` - `tidy_assessment()`

### No Assessment Tests Exist

There is NO test file: - `tests/testthat/test-assessment-live.R` does
NOT exist - `tests/testthat/test-assessment-fidelity.R` does NOT exist

Only test files are: - `tests/testthat/test-enrollment.R` -
`tests/testthat/test-pipeline-live.R` (enrollment pipeline tests)

------------------------------------------------------------------------

## Research Findings (from EXPANSION.md)

### Assessment Data Availability

**Only 2 years of raw assessment data available:** - 2013-14: Strive HI
Master Data File - 2014-15: Strive HI Master Data File

**Data Source URLs:** -
<https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2014/2013-14MasterDataFile.xlsx> -
<https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2015/2014-15MasterDataFile.xlsx>

### Critical Blocker

**NO RAW ASSESSMENT DATA AVAILABLE FOR 2015-16 TO PRESENT**

All subsequent years (2015-16 through present) are only available
through: 1. **ARCH Dashboard** - JavaScript-rendered, no export option
2. **PDF Reports** - Summary tables, not raw data 3. **School report
cards** - Individual school PDFs

### What Data IS Available (2013-14, 2014-15)

From the Master Data Files: - **Subjects:** Math, Reading, Science -
**Metrics:** Proficiency percentages, participation rates, Student
Growth Percentiles (SGP) - **Level:** School-level data (not
student-level) - **Coverage:** ~290 schools (traditional + charter) -
**Format:** Excel (.xlsx) with clean, raw data

### Schema Structure

The Master Data Files contain: - School ID - Year - School Name - School
Type (Elementary/Middle/High) - Title I status - Complex Area - Strive
HI Step (Recognition/Continuous Improvement/Focus/Priority) - Final
Index Score (0-400 points) - Math Proficiency (%) - Reading Proficiency
(%) - Science Proficiency (%) - Participation penalty flags - Pooled
data flags (for small schools) - Median SGP (Student Growth Percentile)

------------------------------------------------------------------------

## Implementation Recommendations

### Option 1: Implement 2-Year Dataset (LIMITED UTILITY)

**Pros:** - Clean, raw Excel data with school-level detail - Math,
Reading, Science proficiency percentages - Student Growth Percentiles
(SGP) - Implementation straightforward - No web scraping needed

**Cons:** - Only 2 years of data (2013-14, 2014-15) - Not useful for
trend analysis - May confuse users expecting recent data - Very limited
historical value

### Option 2: Request Full Data from HIDOE (RECOMMENDED)

Contact Hawaii DOE Research & Evaluation Office for: - Historical Master
Data Files for 2015-16 to present - API access to ARCH data - Bulk data
download option - Automated data access method

**Contact:** - Hawaii DOE Research & Data Requests:
<https://hawaiipublicschools.org/data-reports/research-and-data-requests/> -
Data Request Form:
<https://www.hawaiipublicschools.org/DOE%20Forms/DataGov/DataRequestForm.xlsx>

### Option 3: Web Scraping (NOT RECOMMENDED)

- JavaScript-rendered content (requires Selenium/Playwright)
- No documented API
- May violate Terms of Service
- Extremely fragile (breaks when site changes)
- No guarantee of historical data access
- Ethical/legal concerns

------------------------------------------------------------------------

## Test Requirements (If Implementing 2-Year Dataset)

### Tests That Would Be Needed (30-50+ tests)

**URL Availability Tests (2 tests)** - 2013-14 Master Data File URL
accessible - 2014-15 Master Data File URL accessible

**File Download Tests (2 tests)** - 2013-14 file downloads
successfully - 2014-15 file downloads successfully

**File Parsing Tests (2 tests)** - 2013-14 Excel file can be parsed -
2014-15 Excel file can be parsed

**Pipeline Tests (4 tests)** - `fetch_assessment(2014)` returns data -
`fetch_assessment(2015)` returns data - `fetch_assessment()` rejects
invalid years - `fetch_assessment_multi()` returns combined data

**Column Structure Tests (6 tests)** - 2014 data has expected columns
(school_code, school_name, subject, proficiency_rate, etc.) - 2015 data
has expected columns - All required columns present

**Subject Coverage Tests (3 tests)** - Math data available - Reading
data available - Science data available

**School Coverage Tests (10+ tests)** - Major schools present (Aiea
High, etc.) - School count ~290 (±5 tolerance) - Complex areas present

**Data Quality Tests (8+ tests)** - No Inf/NaN values - Proficiency
rates 0-100 range - Non-negative test counts - No duplicate school-year
combinations

**Fidelity Tests (5+ tests)** - State total matches raw Excel - Specific
school proficiency matches raw Excel - Tidy format preserves raw values

**Multi-Year Fetch Tests (3+ tests)** -
`fetch_assessment_multi(2014:2015)` works - Multiple subjects returned
correctly - Year column correctly populated

**Total: 30-50+ tests required**

------------------------------------------------------------------------

## Implementation Effort Estimate

### If Implementing 2-Year Dataset:

**Files to Create:** 1. `R/get_raw_assessment.R` - Download Master Data
Files 2. `R/process_assessment.R` - Parse Excel files 3.
`R/tidy_assessment.R` - Transform to tidy format 4.
`R/fetch_assessment.R` - User-facing function 5.
`tests/testthat/test-assessment-live.R` - LIVE tests (30-50+ tests) 6.
`tests/testthat/test-assessment-fidelity.R` - Fidelity tests 7.
`vignettes/assessment-trends.Rmd` - Documentation 8.
`man/fetch_assessment.Rd` - Function documentation

**Estimated Time:** 4-6 hours

**Files to Modify:** - `R/hischooldata-package.R` - Add assessment
exports - `README.md` - Add assessment examples - `CLAUDE.md` - Update
data availability section

------------------------------------------------------------------------

## Conclusion

**Hawaii assessment data implementation is SEVERELY LIMITED:**

1.  Only 2 years of raw data (2013-14, 2014-15)
2.  No public data access for 2015-16 to present
3.  ARCH dashboard not programmatic-accessible
4.  Web scraping not recommended without permission

**Can implement:** 2-year assessment dataset (2013-14, 2014-15) **Cannot
implement:** Multi-year trends, recent data

**Recommendation:** - Implement 2-year dataset if user accepts
limitation - OR prioritize different data theme with better
availability - OR contact HIDOE for full historical data access

------------------------------------------------------------------------

## Next Steps

**To implement assessment data for Hawaii:**

1.  **Decision point:** Decide if 2-year dataset is acceptable
2.  **If yes:** Implement following Option 1 above
3.  **If no:** Contact HIDOE for full data access (Option 2)
4.  **Alternative:** Prioritize different data theme (demographics,
    attendance, graduation)

**Current package status:** Assessment NOT implemented, research
complete

------------------------------------------------------------------------

**Status Document Created:** 2026-01-12 **Last Updated:** 2026-01-12
**Research Source:** EXPANSION.md (completed 2026-01-11)
