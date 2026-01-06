# ==============================================================================
# Tests for Hawaii Enrollment Data Functions
# ==============================================================================
#
# These tests verify that enrollment data can be fetched and processed correctly
# for all available years, and that the data maintains fidelity to the raw
# DBEDT Data Book source files.
#
# IMPORTANT: The end_year parameter represents the END of the school year.
# For example, end_year=2024 means the 2023-24 school year.
#
# Data source mapping:
# - end_year 2025 <- 2024 Data Book (2024-25 school year)
# - end_year 2024 <- 2023 Data Book (2023-24 school year)
# - end_year 2011 <- 2010 Data Book (2010-11 school year)
# - end_year 2012 is NOT available (no 2011 Data Book published)
#
# ==============================================================================

# --- Helper Functions ---------------------------------------------------------

skip_if_no_network <- function() {
  skip_on_cran()
  # Test network connectivity
  connected <- tryCatch({
    httr::HEAD("https://files.hawaii.gov/", httr::timeout(5))
    TRUE
  }, error = function(e) FALSE)
  skip_if_not(connected, "No network connection to DBEDT")
}

# --- get_available_years() tests ----------------------------------------------

test_that("get_available_years returns correct structure", {
  years <- get_available_years()

  expect_type(years, "list")
  expect_true("min_year" %in% names(years))
  expect_true("max_year" %in% names(years))
  expect_true("years" %in% names(years))
  expect_true("description" %in% names(years))
})

test_that("get_available_years returns correct range", {
  years <- get_available_years()

  expect_equal(years$min_year, 2011)
  expect_equal(years$max_year, 2025)

  # 2012 should NOT be in the list (no 2011 Data Book published)
  expect_false(2012 %in% years$years)

  # 2011 SHOULD be in the list (from 2010 Data Book)
  expect_true(2011 %in% years$years)

  # All years 2013-2025 should be available
  expect_true(all(2013:2025 %in% years$years))
})

# --- fetch_enr() validation tests ---------------------------------------------

test_that("fetch_enr validates year range", {
  skip_if_no_network()

  # Year before range
  expect_error(fetch_enr(2005), "end_year must be one of")

  # Year 2012 (not available - no 2011 Data Book)
  expect_error(fetch_enr(2012), "end_year must be one of")

  # Year beyond range
  expect_error(fetch_enr(2030), "end_year must be one of")
})

# --- Data Structure Tests -----------------------------------------------------

test_that("fetch_enr returns correct column structure", {
  skip_if_no_network()

  df <- fetch_enr(2024, use_cache = TRUE)

  expected_cols <- c("end_year", "district_id", "district_name", "county_name",
                     "type", "grade_level", "subgroup", "n_students", "pct",
                     "is_state", "is_county", "is_charter")
  expect_true(all(expected_cols %in% names(df)))
})

test_that("fetch_enr returns correct aggregation levels", {
  skip_if_no_network()

  df <- fetch_enr(2024, use_cache = TRUE)

  types <- unique(df$type)
  expect_true("STATE" %in% types)
  expect_true("COUNTY" %in% types)
  expect_true("CHARTER" %in% types)
})

test_that("fetch_enr returns correct county names", {
  skip_if_no_network()

  df <- fetch_enr(2024, use_cache = TRUE)

  expected_counties <- c("State Total", "Honolulu", "Hawaii County", "Maui", "Kauai", "Charter Schools")
  actual_counties <- unique(df$county_name)

  for (county in expected_counties) {
    expect_true(county %in% actual_counties, label = paste("Expected county:", county))
  }
})

test_that("fetch_enr returns correct grade levels", {
  skip_if_no_network()

  df <- fetch_enr(2024, use_cache = TRUE)

  grades <- unique(df$grade_level)

  # Should have TOTAL and grade levels
  expect_true("TOTAL" %in% grades)
  expect_true("K" %in% grades)
  expect_true("01" %in% grades)
  expect_true("12" %in% grades)
})

# --- Data Fidelity Tests: Verify Against Known DBEDT Values -------------------
# These values are manually verified from DBEDT Data Book tables.
# end_year=2024 comes from 2023 Data Book (2023-24 school year data)
# end_year=2025 comes from 2024 Data Book (2024-25 school year data)

test_that("2025 state total matches 2024 Data Book (2024-25 school year)", {
  skip_if_no_network()

  df <- fetch_enr(2025, use_cache = TRUE)

  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  # 2024 Data Book Table 3.13: 2024-25 Total = 167,076
  expect_equal(state_total, 167076)
})

test_that("2025 county totals match 2024 Data Book", {
  skip_if_no_network()

  df <- fetch_enr(2025, use_cache = TRUE)

  # Honolulu is the largest county by far (~62% of state)
  honolulu_total <- df[df$county_name == "Honolulu" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(honolulu_total, 103985)  # Verified from 2024 Data Book

  # Hawaii County
  hawaii_total <- df[df$county_name == "Hawaii County" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(hawaii_total, 22715)

  # Maui
  maui_total <- df[df$county_name == "Maui" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(maui_total, 18734)

  # Kauai
  kauai_total <- df[df$county_name == "Kauai" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(kauai_total, 8548)

  # Charter schools
  charter_total <- df[df$county_name == "Charter Schools" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(charter_total, 13094)
})

test_that("2025 grade-level enrollments match 2024 Data Book", {
  skip_if_no_network()

  df <- fetch_enr(2025, use_cache = TRUE)
  state_df <- df[df$county_name == "State Total", ]

  # Verify specific grade values from 2024 Data Book Table 3.13
  expect_equal(state_df[state_df$grade_level == "PK", "n_students"], 1736)
  expect_equal(state_df[state_df$grade_level == "K", "n_students"], 11746)
  expect_equal(state_df[state_df$grade_level == "01", "n_students"], 12451)
  expect_equal(state_df[state_df$grade_level == "09", "n_students"], 14241)
  expect_equal(state_df[state_df$grade_level == "12", "n_students"], 11905)
})

test_that("2024 state total matches 2023 Data Book (2023-24 school year)", {
  skip_if_no_network()

  df <- fetch_enr(2024, use_cache = TRUE)

  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  # 2023 Data Book: 2023-24 school year total
  expect_equal(state_total, 169308)
})

test_that("2020 state total matches 2019 Data Book (2019-20 school year)", {
  skip_if_no_network()

  df <- fetch_enr(2020, use_cache = TRUE)

  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  # 2019 Data Book: 2019-20 school year total = 181,088
  expect_equal(state_total, 181088)
})

test_that("2017 state total matches 2016 Data Book (2016-17 school year)", {
  skip_if_no_network()

  df <- fetch_enr(2017, use_cache = TRUE)

  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  # 2016 Data Book: 2016-17 school year total
  expect_equal(state_total, 181550)
})

test_that("2013 state total matches 2012 Data Book (2012-13 school year)", {
  skip_if_no_network()

  df <- fetch_enr(2013, use_cache = TRUE)

  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  # 2012 Data Book: 2012-13 school year total
  expect_equal(state_total, 184760)
})

test_that("2011 state total matches 2010 Data Book (2010-11 school year)", {
  skip_if_no_network()

  df <- fetch_enr(2011, use_cache = TRUE)

  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  # 2010 Data Book: 2010-11 school year total
  expect_equal(state_total, 179577)
})

# --- 2021 and 2022 Special Cases (Multi-Year Table in 2021 Data Book) ---------

test_that("2021 correctly extracts 2020-21 data from 2020 Data Book", {
  skip_if_no_network()

  df <- fetch_enr(2021, use_cache = TRUE)

  # 2020 Data Book contains 2020-21 data (but we use 2021 Data Book which has both)
  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  # 2020-21 school year total from 2021 Data Book multi-year table
  expect_equal(state_total, 176441)
})

test_that("2022 correctly extracts 2021-22 data from 2021 Data Book", {
  skip_if_no_network()

  df <- fetch_enr(2022, use_cache = TRUE)

  # 2021 Data Book contains both 2020-21 AND 2021-22 data
  # end_year=2022 should extract 2021-22 data
  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  # Note: 2021-22 total from 2021 Data Book is 173,178 (not 170,209 which is 2022-23)
  expect_equal(state_total, 173178)
})

# --- SPED Data Availability ---------------------------------------------------

test_that("SPED data is available for years 2011-2022", {
  skip_if_no_network()

  # SPED figures are shown separately until 2022
  df <- fetch_enr(2022, use_cache = TRUE)
  grades <- unique(df$grade_level)
  expect_true("SPED" %in% grades)
})

test_that("SPED data is NOT available for 2024-2025", {
  skip_if_no_network()

  # Per 2024 Data Book footnote: "Special Education figures were not shown
  # separately in the 2024-2025 enrollment count"
  df <- fetch_enr(2025, use_cache = TRUE)
  grades <- unique(df$grade_level)
  expect_false("SPED" %in% grades)
})

# --- Data Sanity Checks -------------------------------------------------------

test_that("no zero enrollments where data should exist", {
  skip_if_no_network()

  df <- fetch_enr(2025, use_cache = TRUE)

  # State totals should never be zero
  state_totals <- df[df$county_name == "State Total", "n_students"]
  expect_true(all(state_totals > 0))

  # Grade-level enrollments should be reasonable (> 1000 for most grades)
  state_grades <- df[df$county_name == "State Total" & df$grade_level != "TOTAL", ]
  # PK might be smaller, but K-12 should all be > 10000
  k12_grades <- state_grades[!state_grades$grade_level %in% c("PK", "SPED"), "n_students"]
  expect_true(all(k12_grades > 10000))
})

test_that("no NA enrollments in data", {
  skip_if_no_network()

  df <- fetch_enr(2025, use_cache = TRUE)

  expect_false(any(is.na(df$enrollment)))
})

test_that("county totals sum approximately to state total", {
  skip_if_no_network()

  df <- fetch_enr(2025, use_cache = TRUE)

  # Get totals
  state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  county_totals <- df[df$type == "COUNTY" & df$grade_level == "TOTAL", "n_students"]
  charter_total <- df[df$county_name == "Charter Schools" & df$grade_level == "TOTAL", "n_students"]

  # Counties + Charter should approximately equal State Total
  sum_parts <- sum(county_totals) + charter_total
  expect_equal(sum_parts, state_total)
})

# --- Historical Data Consistency ----------------------------------------------

test_that("enrollment trends are reasonable across years", {
  skip_if_no_network()

  # Get a few years of data (using correct end_years)
  years_to_check <- c(2017, 2020, 2024)
  totals <- sapply(years_to_check, function(yr) {
    df <- fetch_enr(yr, use_cache = TRUE)
    df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
  })

  # Enrollment should be reasonably consistent (no wild swings)
  # Hawaii enrollment has been declining slightly (~182k in 2017 to ~169k in 2024)
  expect_true(all(totals > 160000))
  expect_true(all(totals < 190000))

  # Should show general decline (newer years <= older years)
  expect_true(totals[3] <= totals[1])  # 2024 <= 2017
})

# --- fetch_enr_multi() tests --------------------------------------------------

test_that("fetch_enr_multi returns combined data", {
  skip_if_no_network()

  df <- fetch_enr_multi(c(2023, 2025), use_cache = TRUE)

  expect_true("end_year" %in% names(df))
  expect_true(2023 %in% df$end_year)
  expect_true(2025 %in% df$end_year)

  # Should have data for both years
  n_2023 <- sum(df$end_year == 2023)
  n_2025 <- sum(df$end_year == 2025)
  expect_true(n_2023 > 0)
  expect_true(n_2025 > 0)
})

test_that("fetch_enr_multi validates year 2012 is unavailable", {
  skip_if_no_network()

  # 2012 is not available, should error
  expect_error(fetch_enr_multi(c(2011, 2012, 2013)), "Invalid years: 2012")
})

# --- Cache Tests --------------------------------------------------------------

test_that("cache functions work correctly", {
  skip_if_no_network()

  # Clear cache for a specific year
  clear_cache(2025)

  # First fetch should download
  df1 <- fetch_enr(2025, use_cache = TRUE)

  # Second fetch should use cache (faster)
  df2 <- fetch_enr(2025, use_cache = TRUE)

  # Data should be identical
  expect_equal(nrow(df1), nrow(df2))
  expect_equal(df1$enrollment, df2$enrollment)
})

test_that("cache_status returns information", {
  skip_if_no_network()

  # Ensure we have cached data
  fetch_enr(2025, use_cache = TRUE)

  # cache_status should work without error
  status <- cache_status()
  expect_type(status, "list")
})

# --- safe_numeric() tests -----------------------------------------------------

test_that("safe_numeric handles various inputs", {
  expect_equal(hischooldata:::safe_numeric("123"), 123)
  expect_equal(hischooldata:::safe_numeric("1,234"), 1234)
  expect_equal(hischooldata:::safe_numeric("  456  "), 456)

  # Suppression markers should return NA
  expect_true(is.na(hischooldata:::safe_numeric("*")))
  expect_true(is.na(hischooldata:::safe_numeric("-")))
  expect_true(is.na(hischooldata:::safe_numeric("N/A")))
  expect_true(is.na(hischooldata:::safe_numeric("")))
  expect_true(is.na(hischooldata:::safe_numeric("(1/)")))
})

# --- get_databook_year() tests ------------------------------------------------

test_that("get_databook_year maps correctly", {
  # Basic mapping: db_year = end_year - 1
  expect_equal(hischooldata:::get_databook_year(2025), 2024)
  expect_equal(hischooldata:::get_databook_year(2024), 2023)
  expect_equal(hischooldata:::get_databook_year(2011), 2010)

  # Special case: 2020 uses 2019 Data Book (2020 is duplicate)
  expect_equal(hischooldata:::get_databook_year(2020), 2019)

  # Special case: 2021 uses 2021 Data Book (has 2020-21 data in multi-year table)
  expect_equal(hischooldata:::get_databook_year(2021), 2021)

  # 2022 uses 2021 Data Book (has 2021-22 data in multi-year table)
  expect_equal(hischooldata:::get_databook_year(2022), 2021)
})

# --- Test All Available Years -------------------------------------------------
# This is a comprehensive test that runs against all available years

test_that("all available years return valid data", {
  skip_if_no_network()
  skip_on_cran()  # This test takes a while

  available <- get_available_years()$years

  for (yr in available) {
    df <- fetch_enr(yr, use_cache = TRUE)

    # Basic structure checks
    expect_true(nrow(df) > 50, label = paste("Year", yr, "has enough rows"))
    expect_true("n_students" %in% names(df), label = paste("Year", yr, "has n_students column"))

    # State total should exist and be reasonable
    state_total <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
    expect_true(
      length(state_total) == 1 && state_total > 150000 && state_total < 200000,
      label = paste("Year", yr, "has reasonable state total:", state_total)
    )
  }
})

# --- Year-by-Year Fidelity Tests ----------------------------------------------
# Verify EVERY available year returns expected state totals

test_that("all years return correct state totals", {
  skip_if_no_network()
  skip_on_cran()

  # Expected totals verified from DBEDT Data Books
  # Each end_year maps to data_book_year via get_databook_year()
  expected_totals <- list(
    "2011" = 179577,  # 2010 Data Book -> 2010-11 school year
    "2013" = 184760,  # 2012 Data Book -> 2012-13 school year
    "2014" = 186850,  # 2013 Data Book -> 2013-14 school year
    "2015" = 182384,  # 2014 Data Book -> 2014-15 school year
    "2016" = 181995,  # 2015 Data Book -> 2015-16 school year
    "2017" = 181550,  # 2016 Data Book -> 2016-17 school year
    "2018" = 180837,  # 2017 Data Book -> 2017-18 school year
    "2019" = 181278,  # 2018 Data Book -> 2018-19 school year
    "2020" = 181088,  # 2019 Data Book -> 2019-20 school year
    "2021" = 176441,  # 2021 Data Book -> 2020-21 school year (multi-year table)
    "2022" = 173178,  # 2021 Data Book -> 2021-22 school year (multi-year table)
    "2023" = 170209,  # 2022 Data Book -> 2022-23 school year
    "2024" = 169308,  # 2023 Data Book -> 2023-24 school year
    "2025" = 167076   # 2024 Data Book -> 2024-25 school year
  )

  for (yr_str in names(expected_totals)) {
    yr <- as.integer(yr_str)
    df <- fetch_enr(yr, use_cache = TRUE)
    actual <- df[df$county_name == "State Total" & df$grade_level == "TOTAL", "n_students"]
    expected <- expected_totals[[yr_str]]

    expect_equal(
      actual, expected,
      label = paste("Year", yr, "state total")
    )
  }
})
