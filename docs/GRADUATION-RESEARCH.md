# Hawaii Graduation Rate Data Research

**Research Date:** January 10, 2026
**Package:** hischooldata
**Objective:** Identify viable machine-readable sources for graduation rate data by district/school for Hawaii

---

## Executive Summary

**Viability Tier: 4 - SKIP**

**Recommendation:** Do NOT implement graduation rate data for Hawaii at this time.

**Rationale:**
- Hawaii's graduation rate data is primarily available through JavaScript-rendered web portals (ARCH, LEI Kukui)
- No direct CSV/Excel downloads available for school-level graduation rates with subgroup breakdowns
- Data requires manual interaction with web interfaces or formal data requests
- The only machine-readable format found is a single "KPI Master Data File" Excel file that may not contain the granular data needed
- Accessing the data would require browser automation or formal data request processes, which violates project constraints

---

## Data Sources Investigated

### 1. ARCH (Accountability Resource Center Hawaii)

**URL:** https://arch.k12.hi.us/

**Description:** Hawaii's official accountability and school quality information portal.

**Key Pages:**
- Strive HI Performance Report: https://arch.k12.hi.us/reports/strivehi-performance
- ESSA Report Cards: https://arch.k12.hi.us/reports/essa
- HIDOE Data Book: https://arch.k12.hi.us/reports/hidoe-data-book

**Viability Assessment:** NOT VIABLE
- **Issue:** Entire site is JavaScript-rendered (React.js application)
- **Access Method:** Requires browser interaction; no direct file downloads
- **Data Format:** Individual school reports available as PDFs stored in AWS S3
- **Sample File:** `418_StriveHIMauiHigh25.pdf` (individual school PDF report)

**Technical Constraints:**
- Site returns minimal HTML with content loaded via JavaScript
- Cannot be accessed with simple HTTP requests or scraping tools
- Would require Selenium/Playwright browser automation (violates project guidelines)

---

### 2. LEI Kukui Data Portal

**URL:** https://www.hidoedata.org/

**Description:** Hawaii's official educational data portal for HIDOE.

**Viability Assessment:** NOT VIABLE
- **Issue:** Access forbidden error (403) when attempting to fetch content
- **Status:** Portal appears to be restricted or requires authentication
- **Data Access:** No public API documentation found

**Technical Constraints:**
- Web reader returned: "Access to the requested URL is forbidden"
- May require login credentials or VPN access
- No evidence of public API endpoints

---

### 3. Strive HI Performance System

**URL:** https://arch.k12.hi.us/reports/strivehi-performance

**Description:** Hawaii's school accountability and performance system tracking graduation rates.

**Data Available:**
- Four-year graduation rates for 2023-24: 85.8% (statewide)
- Class of 2024: 86% graduation rate
- Updated September 18, 2025

**Key Finding - KPI Master Data File:**
- **File:** `2024-25KPIMasterDataFileUpdate20251202.xls`
- **Format:** Excel (.xls)
- **Last Updated:** December 2, 2025
- **Location:** Available through ARCH Strive HI Performance Report page

**Viability Assessment:** SPECIAL CASE (Requires Investigation)
- **Potential:** This Excel file may contain the data needed
- **Issue:** Cannot determine file structure or content without downloading
- **Access:** Must interact with JavaScript web interface to download
- **Uncertainty:** Unknown if file contains school-level graduation rates with subgroups

---

### 4. Hawaii Public Schools - School Reports

**URL:** https://hawaiipublicschools.org/data-reports/school-reports/

**Description:** Official source for enrollment data and Strive HI Performance System information.

**Available Downloads:**
- Enrollment Data (2025-26 through 2017-18): Excel files available
- Title I Schools: PDF format only
- **Graduation Rate Data:** NOT available as direct download

**Viability Assessment:** NOT VIABLE FOR GRADUATION RATES
- **Issue:** Only enrollment data available as Excel downloads
- **Missing:** No graduation rate files in the downloads section
- **Access:** Graduation data requires navigating to ARCH portal (JavaScript-rendered)

---

### 5. HIDOE Data Governance and Data Requests

**URL:** https://hawaiipublicschools.org/data-reports/research-and-data-requests/

**Description:** Official process for requesting data from Hawaii DOE.

**Data Request Process:**
- Complete Data Request Form (Excel)
- Submit to Data Governance and Analysis Branch
- Data delivery via CSV files
- **Approval Required:** HIDOE must approve all data requests
- **Timeline:** Research Review Committee meets on scheduled dates

**Viability Assessment:** NOT VIABLE
- **Issue:** Requires formal approval process
- **Timeline:** Not automated; depends on committee schedule
- **Manual Process:** Violates project requirement for automated data access
- **Restrictions:** DGA retains right to refuse any request

---

### 6. Strive HI Technical Guides (PDFs)

**Available Years:** 2017 through 2024

**URL Pattern:** https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI{YEAR}/StriveHITechnicalGuide{YEAR}.pdf

**Content:**
- Definitions and calculation methods for graduation rates
- Subgroup categories tracked
- Data quality requirements
- **Format:** PDF documents with methodology, not raw data

**Viability Assessment:** NOT VIABLE
- **Issue:** Technical guides explain methodology but don't contain raw data
- **Format:** PDF (cannot be machine-parsed easily)
- **Purpose:** Documentation, not data source

---

### 7. Strive HI State Reports (PDFs)

**Available Reports:**
- State of Hawaiʻi Public Schools Statewide Strive HI Report 2024
- State of Hawaiʻi Public Schools Statewide Strive HI Report 2025
- Annual reports from Board of Education

**URL:** https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2024/StriveHIStateReport2024.pdf

**Content:**
- Statewide graduation rates
- Some school-level data
- Subgroup breakdowns (race/ethnicity, gender, disability status, ELL)
- **Format:** PDF

**Viability Assessment:** NOT VIABLE
- **Issue:** PDF format requires scraping/parsing
- **Inconsistent:** Data tables may vary year-to-year
- **Effort:** High maintenance burden for PDF parsing
- **Reliability:** PDF layouts can change without notice

---

## Data Structure Analysis

### Known Data Elements (from Technical Guides)

**Graduation Rate Subgroups Tracked:**
- Race/Ethnicity (major racial/ethnic groups)
- Gender
- Economically Disadvantaged
- Students with Disabilities (IDEA)
- English Language Learners (ELL)
- Migrant Status
- Homeless Status
- Military-Connected Students

**Geographic Levels:**
- Statewide
- Complex Area (Hawaii's equivalent of districts)
- School-level

**Years Available:**
- 2018-19 through 2023-24 (5 years available)
- 2024-25 data expected summer/fall 2025

**Sample Data Points:**
- 2023-24 Statewide: 85.8% four-year graduation rate
- Class of 2024: 86% graduation rate
- English Learners: 90% graduation rate (vs. 86% non-EL)
- College Enrollment (Class of 2024): 53%

---

## Technical Barriers

### JavaScript-Rendered Interfaces

**Problem:** Both ARCH and LEI Kukui use modern JavaScript frameworks (React.js) that render content client-side.

**Evidence:**
```html
<!-- ARCH site HTML -->
<div id="root"></div>
<script src="/static/js/2.eb4ddac7.chunk.js"></script>
<script src="/static/js/main.471608cf.chunk.js"></script>
```

**Implication:**
- Cannot use simple HTTP requests (httr, requests)
- Cannot parse static HTML
- Requires browser automation (Selenium, Playwright)
- Violates project constraint: "Avoid: JavaScript-rendered sites"

### PDF-Only Reports

**Problem:** Most detailed graduation rate data is only available in PDF format.

**Examples:**
- Individual school Strive HI reports
- Statewide Strive HI reports
- ESSA report cards
- Special education graduation reports

**Implication:**
- PDF parsing is fragile and error-prone
- Layout changes break parsers
- High maintenance burden
- Not recommended for automated data pipelines

### Formal Request Requirements

**Problem:** Access to CSV data requires formal approval process.

**Process:**
1. Complete Data Request Form
2. Submit to Data Governance and Analysis Branch
3. Wait for committee review
4. Execute Data Sharing Agreement
5. Receive CSV files

**Implication:**
- Not automatable
- Timeline uncertainty
- Approval not guaranteed
- One-time data delivery, not ongoing access

---

## Alternative Approaches Considered

### 1. Browser Automation (Selenium/Playwright)

**Approach:** Automate web browser to interact with ARCH portal and download files.

**Pros:**
- Can access JavaScript-rendered content
- Can download Excel files if accessible

**Cons:**
- Heavy dependency (browser drivers)
- Fragile (UI changes break scripts)
- Resource-intensive
- May violate website ToS
- Against project guidelines

**Verdict:** NOT RECOMMENDED

### 2. KPI Master Data File Investigation

**Approach:** Download and analyze `2024-25KPIMasterDataFileUpdate20251202.xls` to determine if it contains needed data.

**Pros:**
- Single Excel file (easy to parse)
- May contain all schools and subgroups
- Official HIDOE source

**Cons:**
- Cannot download without browser automation
- Unknown data structure
- Unknown if historical files exist (2021-2024)
- May not contain subgroup breakdowns

**Verdict:** WORTH MANUAL INVESTIGATION (one-time download)

**Action Item:** Manually download the Excel file via browser and inspect structure. If it contains school-level graduation rates with subgroups for multiple years, consider implementing with a one-time manual download process.

### 3. Contact HIDOE Data Governance Branch

**Approach:** Contact HIDOE to request automated access to graduation rate data or API endpoint.

**Pros:**
- May get access to API or automated CSV downloads
- Official channel ensures compliance
- Could establish ongoing data access

**Cons:**
- No guarantee of positive response
- Timeline uncertain
- May require formal agreement
- Not immediate solution

**Verdict:** WORTH ATTEMPTING (long-term solution)

**Action Item:** Contact Data Governance and Analysis Branch (DGA) at (808) 784-6061 or via email to inquire about:
- API access to graduation rate data
- Automated CSV download options
- Bulk data access for research purposes

### 4. Hawaii Open Data Portal

**Approach:** Check if graduation rate data is available through Hawaii's open data portal.

**Status:** Searched but no graduation rate datasets found

**URL:** https://opendata.hawaii.gov/

**Verdict:** NO DATA AVAILABLE

---

## Recommendations

### Primary Recommendation: SKIP (Tier 4)

**Rationale:**
1. **JavaScript-Rendered Barrier:** Primary data source (ARCH) requires browser automation
2. **No Direct Downloads:** No CSV/Excel files available for graduation rates with subgroups
3. **PDF-Only Data:** Detailed reports only in PDF format (high maintenance burden)
4. **Manual Request Required:** Automated access not available without formal approval
5. **Project Constraints:** Violates "Avoid JavaScript-rendered sites" and "Find automated alternatives" rules

**Exception:** If manual investigation of the KPI Master Data File reveals it contains the needed data structure, consider implementation with a one-time manual download process.

---

### Alternative Path Forward (If Implementation Required)

**Step 1: Manual KPI File Investigation**
- Manually visit https://arch.k12.hi.us/reports/strivehi-performance
- Download `2024-25KPIMasterDataFileUpdate20251202.xls`
- Inspect file structure for:
  - School-level graduation rates
  - Subgroup breakdowns
  - Historical years (2021-2024)
  - Data quality (completeness, formatting)

**Step 2: If File Contains Needed Data**
- Store file in package data directory
- Create R function to read and parse Excel file
- Add note that data must be manually updated
- Document as "special case" package requiring manual data refresh

**Step 3: If File Inadequate**
- Contact HIDOE Data Governance Branch
- Request automated data access or API
- If denied, implement `import_local_graduation()` fallback
- Document that users must obtain data directly from HIDOE

---

## Contact Information

**Hawaii Department of Education**
**Data Governance and Analysis Branch (DGA)**
- Phone: (808) 784-6061
- Email: Available on research request page
- URL: https://hawaiipublicschools.org/data-reports/research-and-data-requests/

**Board of Education (BOE)**
- Student Achievement Committee
- URL: https://boe.hawaii.gov/

---

## Sources

- [ARCH - Accountability Resource Center Hawaii](https://arch.k12.hi.us/)
- [HIDOE Data Book](https://arch.k12.hi.us/reports/hidoe-data-book)
- [Strive HI Performance Report](https://arch.k12.hi.us/reports/strivehi-performance)
- [School Reports – Hawaiʻi State Department of Education](https://hawaiipublicschools.org/data-reports/school-reports/)
- [Research and Data Requests](https://hawaiipublicschools.org/data-reports/research-and-data-requests/)
- [Every Student Succeeds Act (ESSA) Report Cards](https://arch.k12.hi.us/reports/essa)
- [Strive HI Dashboard](https://hawaiipublicschools.org/about/organization/strive-hi-dashboard/)
- [State of Hawaiʻi Public Schools Statewide Strive HI Report 2024](https://www.hawaiipublicschools.org/DOE%20Forms/StriveHI2024/StriveHIStateReport2024.pdf)
- [Hawaiʻi English Learners' Data Story](https://www.hawaiidxp.org/data-products/hawaii-english-language-learners-data-story/)
- [Graduation Dropout Rates of Suspension & Expulsion](https://hawaiipublicschools.org/DOE%20Forms/Special%20Education/IDEA%20SPP%20APR%20Indicators/Indicators1-2-4-Graduation_Dropout_Suspension_Expulsion.pdf)
- [Publicly Available HIDOE Reports](https://hawaiipublicschools.org/wp-content/uploads/Publicly-Available-HIDOE-Reports.pdf)

---

**Document Status:** Complete
**Next Review:** If KPI Master Data File is investigated or HIDOE provides automated access
