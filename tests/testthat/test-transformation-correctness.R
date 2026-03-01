# ==============================================================================
# Transformation Correctness Tests for hischooldata
# ==============================================================================
#
# These tests verify the correctness of data transformations at every stage:
# suppression handling, ID assignment, grade normalization, subgroup naming,
# pivot fidelity, percentage columns, aggregation logic, entity flags,
# per-year known values, and cross-year consistency.
#
# Every expected value is verified from real DBEDT Data Book output.
# No fabricated or hardcoded test data.
#
# ==============================================================================

library(testthat)

skip_if_no_network <- function() {
  skip_on_cran()
  connected <- tryCatch({
    httr::HEAD("https://files.hawaii.gov/", httr::timeout(5))
    TRUE
  }, error = function(e) FALSE)
  skip_if_not(connected, "No network connection to DBEDT")
}


# ==============================================================================
# SECTION 1: Suppression Handling (safe_numeric)
# ==============================================================================

test_that("safe_numeric converts valid numbers correctly", {
  expect_equal(hischooldata:::safe_numeric("123"), 123)
  expect_equal(hischooldata:::safe_numeric("0"), 0)
  expect_equal(hischooldata:::safe_numeric("1,234"), 1234)
  expect_equal(hischooldata:::safe_numeric("12,345,678"), 12345678)
  expect_equal(hischooldata:::safe_numeric("  456  "), 456)
  expect_equal(hischooldata:::safe_numeric("99.5"), 99.5)
})

test_that("safe_numeric returns NA for suppression markers", {
  markers <- c("*", ".", "-", "-1", "<5", "N/A", "NA", "", "n/a")
  for (m in markers) {
    expect_true(is.na(hischooldata:::safe_numeric(m)),
                label = paste0("Marker '", m, "' should be NA"))
  }
})

test_that("safe_numeric returns NA for non-numeric strings", {
  expect_true(is.na(hischooldata:::safe_numeric("abc")))
  expect_true(is.na(hischooldata:::safe_numeric("(1/)")))
  expect_true(is.na(hischooldata:::safe_numeric("Source:")))
})

test_that("safe_numeric handles vector input", {
  result <- hischooldata:::safe_numeric(c("100", "*", "200", "-", "1,500"))
  expect_equal(result, c(100, NA, 200, NA, 1500))
})


# ==============================================================================
# SECTION 2: ID and Identifier Columns
# ==============================================================================

test_that("district_id is always 'HI' (single statewide district)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_true(all(df$district_id == "HI"))
  expect_equal(length(unique(df$district_id)), 1)
})

test_that("district_name is always 'Hawaii Department of Education'", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_true(all(df$district_name == "Hawaii Department of Education"))
  expect_equal(length(unique(df$district_name)), 1)
})

test_that("IDs are consistent across years", {
  skip_if_no_network()

  df_old <- fetch_enr(2011, tidy = TRUE, use_cache = TRUE)
  df_new <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expect_equal(unique(df_old$district_id), unique(df_new$district_id))
  expect_equal(unique(df_old$district_name), unique(df_new$district_name))
})


# ==============================================================================
# SECTION 3: Grade Level Normalization
# ==============================================================================

test_that("grade levels use standard uppercase format (2025)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  grades <- unique(df$grade_level)

  # Must contain standard grades
  expect_true("TOTAL" %in% grades)
  expect_true("PK" %in% grades)
  expect_true("K" %in% grades)
  for (g in sprintf("%02d", 1:12)) {
    expect_true(g %in% grades, label = paste("Grade", g, "should exist"))
  }

  # All grade levels should be uppercase
  expect_true(all(grades == toupper(grades)))
})

test_that("grade levels include SPED for years that have it (2022)", {
  skip_if_no_network()

  df <- fetch_enr(2022, tidy = TRUE, use_cache = TRUE)
  expect_true("SPED" %in% unique(df$grade_level))
})

test_that("grade levels exclude SPED for years that lack it (2025)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_false("SPED" %in% unique(df$grade_level))
})

test_that("no raw grade names leak through (Pre-Kindergarten, Special Ed.)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  grades <- unique(df$grade_level)

  # These are raw DBEDT names that should be normalized

  bad_names <- c("Pre-Kindergarten", "Nursery", "Pre-K", "Kindergarten",
                 "Special Ed.", "Special Education", "All grades", "Total")
  for (name in bad_names) {
    expect_false(name %in% grades,
                 label = paste("Raw grade name", name, "should not appear"))
  }
})

test_that("single-digit grades are zero-padded (01 not 1)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  grades <- unique(df$grade_level)

  # Single digit grades should NOT appear
  for (g in as.character(1:9)) {
    expect_false(g %in% grades,
                 label = paste("Unpadded grade", g, "should not appear"))
  }

  # Two-digit versions should appear
  for (g in sprintf("%02d", 1:9)) {
    expect_true(g %in% grades,
                label = paste("Padded grade", g, "should appear"))
  }
})


# ==============================================================================
# SECTION 4: Subgroup Naming Standards
# ==============================================================================

test_that("subgroup is always 'total_enrollment' (HI has no demographic splits)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_equal(unique(df$subgroup), "total_enrollment")
})

test_that("subgroup naming is consistent across years", {
  skip_if_no_network()

  df_old <- fetch_enr(2011, tidy = TRUE, use_cache = TRUE)
  df_new <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expect_equal(unique(df_old$subgroup), "total_enrollment")
  expect_equal(unique(df_new$subgroup), "total_enrollment")
})

test_that("no non-standard subgroup names appear", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  bad_names <- c("total", "Total", "all", "All", "enrollment", "Total Enrollment")
  expect_false(any(df$subgroup %in% bad_names))
})


# ==============================================================================
# SECTION 5: Pivot Fidelity (raw enrollment -> tidy n_students)
# ==============================================================================

test_that("tidy n_students exactly matches raw enrollment values (2025)", {
  skip_if_no_network()

  raw <- hischooldata:::get_raw_enr(2025)
  tidy <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  # Check specific cells: raw$enrollment == tidy$n_students
  for (county in unique(raw$county_name)) {
    for (grade in unique(raw$grade)) {
      raw_val <- raw[raw$county_name == county & raw$grade == grade, "enrollment"]
      tidy_val <- tidy[tidy$county_name == county & tidy$grade_level == grade, "n_students"]

      if (length(raw_val) == 1 && length(tidy_val) == 1 && !is.na(raw_val)) {
        expect_equal(tidy_val, raw_val,
                     label = paste("Fidelity check:", county, grade))
      }
    }
  }
})

test_that("tidy n_students matches raw for 2024", {
  skip_if_no_network()

  raw <- hischooldata:::get_raw_enr(2024)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # State Total TOTAL
  expect_equal(
    tidy[tidy$county_name == "State Total" & tidy$grade_level == "TOTAL", "n_students"],
    raw[raw$county_name == "State Total" & raw$grade == "TOTAL", "enrollment"]
  )

  # Honolulu K
  expect_equal(
    tidy[tidy$county_name == "Honolulu" & tidy$grade_level == "K", "n_students"],
    raw[raw$county_name == "Honolulu" & raw$grade == "K", "enrollment"]
  )

  # Kauai 09
  expect_equal(
    tidy[tidy$county_name == "Kauai" & tidy$grade_level == "09", "n_students"],
    raw[raw$county_name == "Kauai" & raw$grade == "09", "enrollment"]
  )
})

test_that("no rows are gained or lost in tidy transformation (2025)", {
  skip_if_no_network()

  raw <- hischooldata:::get_raw_enr(2025)
  tidy <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  # Same number of rows (tidy doesn't add/remove rows, just renames columns)
  expect_equal(nrow(raw), nrow(tidy))
})

test_that("no duplicate rows exist after transformation", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  dupes <- df %>%
    dplyr::count(county_name, grade_level, subgroup) %>%
    dplyr::filter(n > 1)

  expect_equal(nrow(dupes), 0,
               label = "No duplicate (county, grade, subgroup) combos")
})


# ==============================================================================
# SECTION 6: Percentage Column
# ==============================================================================

test_that("pct column is all NA for Hawaii (no demographic data)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_true(all(is.na(df$pct)))
})

test_that("pct column is NA across all years", {
  skip_if_no_network()

  for (yr in c(2011, 2020, 2025)) {
    df <- fetch_enr(yr, tidy = TRUE, use_cache = TRUE)
    expect_true(all(is.na(df$pct)),
                label = paste("Year", yr, "pct should be all NA"))
  }
})


# ==============================================================================
# SECTION 7: Aggregation Logic
# ==============================================================================

test_that("state TOTAL equals sum of grade-level rows (2025)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  state <- df[df$is_state, ]

  grade_sum <- sum(state[state$grade_level != "TOTAL", "n_students"])
  total_row <- state[state$grade_level == "TOTAL", "n_students"]

  expect_equal(grade_sum, total_row)
})

test_that("each county TOTAL equals sum of its grade-level rows (2025)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  for (county in c("Honolulu", "Hawaii County", "Maui", "Kauai", "Charter Schools")) {
    county_df <- df[df$county_name == county, ]
    grade_sum <- sum(county_df[county_df$grade_level != "TOTAL", "n_students"])
    total_row <- county_df[county_df$grade_level == "TOTAL", "n_students"]

    expect_equal(grade_sum, total_row,
                 label = paste(county, "TOTAL vs grade sum"))
  }
})

test_that("county + charter totals sum to state total (2025)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  county_sum <- sum(df[df$is_county & df$grade_level == "TOTAL", "n_students"])
  charter_total <- df[df$is_charter & df$grade_level == "TOTAL", "n_students"]
  state_total <- df[df$is_state & df$grade_level == "TOTAL", "n_students"]

  expect_equal(county_sum + charter_total, state_total)
})

test_that("county + charter totals sum to state total (2024)", {
  skip_if_no_network()

  df <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  county_sum <- sum(df[df$is_county & df$grade_level == "TOTAL", "n_students"])
  charter_total <- df[df$is_charter & df$grade_level == "TOTAL", "n_students"]
  state_total <- df[df$is_state & df$grade_level == "TOTAL", "n_students"]

  expect_equal(county_sum + charter_total, state_total)
})

test_that("per-grade county + charter sums equal state per-grade (2025)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  for (grade in c("PK", "K", "01", "06", "09", "12", "TOTAL")) {
    county_sum <- sum(df[df$is_county & df$grade_level == grade, "n_students"])
    charter_val <- df[df$is_charter & df$grade_level == grade, "n_students"]
    state_val <- df[df$is_state & df$grade_level == grade, "n_students"]

    expect_equal(county_sum + charter_val, state_val,
                 label = paste("Grade", grade, "county+charter == state"))
  }
})


# ==============================================================================
# SECTION 8: Entity Flags
# ==============================================================================

test_that("entity flags are mutually exclusive and exhaustive", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  # Every row has exactly one TRUE flag
  flag_sum <- as.integer(df$is_state) + as.integer(df$is_county) + as.integer(df$is_charter)
  expect_true(all(flag_sum == 1),
              label = "Every row has exactly one entity flag TRUE")
})

test_that("is_state flag matches type == STATE", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_identical(df$is_state, df$type == "STATE")
})

test_that("is_county flag matches type == COUNTY", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_identical(df$is_county, df$type == "COUNTY")
})

test_that("is_charter flag matches type == CHARTER", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_identical(df$is_charter, df$type == "CHARTER")
})

test_that("entity flag row counts are correct (2025: 15 state, 60 county, 15 charter)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expect_equal(sum(df$is_state), 15)    # 15 grade levels x 1 state entity
  expect_equal(sum(df$is_county), 60)   # 15 grade levels x 4 counties
  expect_equal(sum(df$is_charter), 15)  # 15 grade levels x 1 charter entity
})

test_that("aggregation_flag is 'state' for STATE rows and 'district' for others", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expect_true(all(df$aggregation_flag[df$is_state] == "state"))
  expect_true(all(df$aggregation_flag[!df$is_state] == "district"))
})

test_that("county_name values match type flags correctly", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  # State Total -> is_state
  expect_true(all(df[df$county_name == "State Total", "is_state"]))

  # Four counties -> is_county
  for (county in c("Honolulu", "Hawaii County", "Maui", "Kauai")) {
    expect_true(all(df[df$county_name == county, "is_county"]),
                label = paste(county, "should be is_county"))
  }

  # Charter Schools -> is_charter
  expect_true(all(df[df$county_name == "Charter Schools", "is_charter"]))
})

test_that("exactly 6 county_name values exist", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expected <- c("State Total", "Honolulu", "Hawaii County", "Maui", "Kauai", "Charter Schools")
  actual <- sort(unique(df$county_name))

  expect_equal(sort(actual), sort(expected))
})


# ==============================================================================
# SECTION 9: Per-Year Known Values (verified from DBEDT Data Books)
# ==============================================================================

test_that("2025 state total is 167,076 (2024 Data Book)", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  val <- df[df$is_state & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 167076)
})

test_that("2025 Honolulu total is 103,985", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  val <- df[df$county_name == "Honolulu" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 103985)
})

test_that("2025 Hawaii County total is 22,715", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  val <- df[df$county_name == "Hawaii County" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 22715)
})

test_that("2025 Maui total is 18,734", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  val <- df[df$county_name == "Maui" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 18734)
})

test_that("2025 Kauai total is 8,548", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  val <- df[df$county_name == "Kauai" & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 8548)
})

test_that("2025 Charter total is 13,094", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  val <- df[df$is_charter & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 13094)
})

test_that("2025 state grade-level values match Data Book", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  state <- df[df$is_state, ]

  expect_equal(state[state$grade_level == "PK", "n_students"], 1736)
  expect_equal(state[state$grade_level == "K", "n_students"], 11746)
  expect_equal(state[state$grade_level == "01", "n_students"], 12451)
  expect_equal(state[state$grade_level == "02", "n_students"], 13115)
  expect_equal(state[state$grade_level == "03", "n_students"], 13336)
  expect_equal(state[state$grade_level == "04", "n_students"], 12822)
  expect_equal(state[state$grade_level == "05", "n_students"], 13376)
  expect_equal(state[state$grade_level == "06", "n_students"], 13312)
  expect_equal(state[state$grade_level == "07", "n_students"], 12797)
  expect_equal(state[state$grade_level == "08", "n_students"], 12675)
  expect_equal(state[state$grade_level == "09", "n_students"], 14241)
  expect_equal(state[state$grade_level == "10", "n_students"], 10938)
  expect_equal(state[state$grade_level == "11", "n_students"], 12626)
  expect_equal(state[state$grade_level == "12", "n_students"], 11905)
})

test_that("2024 state total is 169,308 (2023 Data Book)", {
  skip_if_no_network()

  df <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- df[df$is_state & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 169308)
})

test_that("2024 county totals match Data Book", {
  skip_if_no_network()

  df <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  expect_equal(df[df$county_name == "Honolulu" & df$grade_level == "TOTAL", "n_students"], 105712)
  expect_equal(df[df$county_name == "Hawaii County" & df$grade_level == "TOTAL", "n_students"], 22880)
  expect_equal(df[df$county_name == "Maui" & df$grade_level == "TOTAL", "n_students"], 19541)
  expect_equal(df[df$county_name == "Kauai" & df$grade_level == "TOTAL", "n_students"], 8729)
  expect_equal(df[df$is_charter & df$grade_level == "TOTAL", "n_students"], 12446)
})

test_that("2024 specific grade-level values match Data Book", {
  skip_if_no_network()

  df <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  expect_equal(df[df$county_name == "Honolulu" & df$grade_level == "K", "n_students"], 7640)
  expect_equal(df[df$county_name == "Kauai" & df$grade_level == "09", "n_students"], 707)
  expect_equal(df[df$county_name == "Hawaii County" & df$grade_level == "06", "n_students"], 1666)
  expect_equal(df[df$county_name == "Maui" & df$grade_level == "12", "n_students"], 1314)
  expect_equal(df[df$is_charter & df$grade_level == "PK", "n_students"], 19)
  expect_equal(df[df$is_state & df$grade_level == "PK", "n_students"], 1659)
})

test_that("2020 state total is 181,088 (2019 Data Book)", {
  skip_if_no_network()

  df <- fetch_enr(2020, tidy = TRUE, use_cache = TRUE)
  val <- df[df$is_state & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 181088)
})

test_that("2022 state total is 173,178 (2021 Data Book multi-year table)", {
  skip_if_no_network()

  df <- fetch_enr(2022, tidy = TRUE, use_cache = TRUE)
  val <- df[df$is_state & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 173178)
})

test_that("2022 SPED state enrollment is 17,979", {
  skip_if_no_network()

  df <- fetch_enr(2022, tidy = TRUE, use_cache = TRUE)
  val <- df[df$is_state & df$grade_level == "SPED", "n_students"]
  expect_equal(val, 17979)
})

test_that("2011 state total is 179,577 (2010 Data Book)", {
  skip_if_no_network()

  df <- fetch_enr(2011, tidy = TRUE, use_cache = TRUE)
  val <- df[df$is_state & df$grade_level == "TOTAL", "n_students"]
  expect_equal(val, 179577)
})


# ==============================================================================
# SECTION 10: Cross-Year Consistency
# ==============================================================================

test_that("column schema is identical across years", {
  skip_if_no_network()

  df_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  df_2025 <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expect_equal(names(df_2024), names(df_2025))
})

test_that("column types are consistent across years", {
  skip_if_no_network()

  df_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  df_2025 <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  for (col in names(df_2024)) {
    expect_equal(class(df_2024[[col]]), class(df_2025[[col]]),
                 label = paste("Column", col, "type consistent"))
  }
})

test_that("entity names are stable across years", {
  skip_if_no_network()

  df_old <- fetch_enr(2011, tidy = TRUE, use_cache = TRUE)
  df_new <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expect_equal(sort(unique(df_old$county_name)), sort(unique(df_new$county_name)))
})

test_that("type values are stable across years", {
  skip_if_no_network()

  df_old <- fetch_enr(2011, tidy = TRUE, use_cache = TRUE)
  df_new <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expect_equal(sort(unique(df_old$type)), sort(unique(df_new$type)))
})

test_that("end_year column matches requested year", {
  skip_if_no_network()

  for (yr in c(2011, 2020, 2024, 2025)) {
    df <- fetch_enr(yr, tidy = TRUE, use_cache = TRUE)
    expect_true(all(df$end_year == yr),
                label = paste("end_year should be", yr))
  }
})

test_that("enrollment is always non-negative whole numbers", {
  skip_if_no_network()

  for (yr in c(2011, 2020, 2024, 2025)) {
    df <- fetch_enr(yr, tidy = TRUE, use_cache = TRUE)
    expect_true(all(df$n_students >= 0, na.rm = TRUE),
                label = paste("Year", yr, "no negatives"))
    expect_true(all(df$n_students == floor(df$n_students), na.rm = TRUE),
                label = paste("Year", yr, "whole numbers only"))
  }
})

test_that("no Inf or NaN in n_students", {
  skip_if_no_network()

  for (yr in c(2011, 2020, 2024, 2025)) {
    df <- fetch_enr(yr, tidy = TRUE, use_cache = TRUE)
    expect_false(any(is.infinite(df$n_students)),
                 label = paste("Year", yr, "no Inf"))
    expect_false(any(is.nan(df$n_students)),
                 label = paste("Year", yr, "no NaN"))
  }
})

test_that("state totals show reasonable enrollment range (160k-190k)", {
  skip_if_no_network()

  years <- c(2011, 2013, 2017, 2020, 2024, 2025)
  for (yr in years) {
    df <- fetch_enr(yr, tidy = TRUE, use_cache = TRUE)
    state_total <- df[df$is_state & df$grade_level == "TOTAL", "n_students"]

    expect_true(state_total > 160000,
                label = paste("Year", yr, "total >160k"))
    expect_true(state_total < 190000,
                label = paste("Year", yr, "total <190k"))
  }
})

test_that("multi-year fetch preserves per-year values", {
  skip_if_no_network()

  multi <- fetch_enr_multi(c(2024, 2025), tidy = TRUE, use_cache = TRUE)

  # Check 2024 state total in multi-year output
  val_2024 <- multi[multi$end_year == 2024 & multi$is_state &
                    multi$grade_level == "TOTAL", "n_students"]
  expect_equal(val_2024, 169308)

  # Check 2025 state total in multi-year output
  val_2025 <- multi[multi$end_year == 2025 & multi$is_state &
                    multi$grade_level == "TOTAL", "n_students"]
  expect_equal(val_2025, 167076)
})

test_that("multi-year fetch has correct row counts", {
  skip_if_no_network()

  multi <- fetch_enr_multi(c(2024, 2025), tidy = TRUE, use_cache = TRUE)

  # 2024 and 2025 both have 90 rows (15 grades x 6 entities, no SPED)
  expect_equal(sum(multi$end_year == 2024), 90)
  expect_equal(sum(multi$end_year == 2025), 90)
  expect_equal(nrow(multi), 180)
})

test_that("Honolulu is consistently the largest county", {
  skip_if_no_network()

  for (yr in c(2011, 2020, 2025)) {
    df <- fetch_enr(yr, tidy = TRUE, use_cache = TRUE)
    county_totals <- df[df$is_county & df$grade_level == "TOTAL", ]
    max_county <- county_totals[which.max(county_totals$n_students), "county_name"]

    expect_equal(max_county, "Honolulu",
                 label = paste("Year", yr, "Honolulu is largest county"))
  }
})

test_that("Kauai is consistently the smallest county", {
  skip_if_no_network()

  for (yr in c(2011, 2020, 2025)) {
    df <- fetch_enr(yr, tidy = TRUE, use_cache = TRUE)
    county_totals <- df[df$is_county & df$grade_level == "TOTAL", ]
    min_county <- county_totals[which.min(county_totals$n_students), "county_name"]

    expect_equal(min_county, "Kauai",
                 label = paste("Year", yr, "Kauai is smallest county"))
  }
})


# ==============================================================================
# SECTION 11: Data Book Year Mapping
# ==============================================================================

test_that("get_databook_year handles standard mapping", {
  expect_equal(hischooldata:::get_databook_year(2025), 2024)
  expect_equal(hischooldata:::get_databook_year(2024), 2023)
  expect_equal(hischooldata:::get_databook_year(2011), 2010)
})

test_that("get_databook_year handles special cases", {
  # 2020 uses 2019 Data Book (2020 is duplicate)
  expect_equal(hischooldata:::get_databook_year(2020), 2019)

  # 2021 uses 2021 Data Book (multi-year table)
  expect_equal(hischooldata:::get_databook_year(2021), 2021)

  # 2022 maps to 2021 via default formula (end_year - 1)
  expect_equal(hischooldata:::get_databook_year(2022), 2021)
})

test_that("detect_format_era returns correct era", {
  expect_equal(hischooldata:::detect_format_era(2020), "hidoe_modern")
  expect_equal(hischooldata:::detect_format_era(2018), "hidoe_modern")
  expect_equal(hischooldata:::detect_format_era(2015), "dbedt_recent")
  expect_equal(hischooldata:::detect_format_era(2010), "dbedt_recent")
  expect_equal(hischooldata:::detect_format_era(2009), "dbedt_historical")
})


# ==============================================================================
# SECTION 12: Tidy Output Schema Completeness
# ==============================================================================

test_that("tidy output has all required columns", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  required <- c("end_year", "district_id", "district_name", "county_name",
                 "type", "grade_level", "subgroup", "n_students", "pct",
                 "aggregation_flag", "is_state", "is_county", "is_charter")

  for (col in required) {
    expect_true(col %in% names(df),
                label = paste("Required column:", col))
  }
})

test_that("tidy output column order matches spec", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expected_order <- c("end_year", "district_id", "district_name", "county_name",
                      "type", "grade_level", "subgroup", "n_students", "pct",
                      "aggregation_flag", "is_state", "is_county", "is_charter")

  expect_equal(names(df), expected_order)
})

test_that("boolean columns are actually logical type", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  expect_type(df$is_state, "logical")
  expect_type(df$is_county, "logical")
  expect_type(df$is_charter, "logical")
})

test_that("n_students is numeric type", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_true(is.numeric(df$n_students))
})

test_that("end_year is numeric type", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_true(is.numeric(df$end_year))
})

test_that("character columns are character type", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)

  char_cols <- c("district_id", "district_name", "county_name", "type",
                 "grade_level", "subgroup", "aggregation_flag")
  for (col in char_cols) {
    expect_type(df[[col]], "character")
  }
})

test_that("no NA values in n_students column", {
  skip_if_no_network()

  df <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  expect_false(any(is.na(df$n_students)))
})
