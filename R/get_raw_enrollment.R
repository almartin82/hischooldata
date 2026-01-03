# ==============================================================================
# Raw Enrollment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from Hawaii
# Department of Education (HIDOE) and related sources.
#
# Data comes from multiple sources depending on the year:
# - HIDOE Official Enrollment (2018+): Excel files from hawaiipublicschools.org
# - DBEDT State Data Book (2010-2017): Excel tables from files.hawaii.gov
# - Historical DBEDT (pre-2010): Older format data book tables
#
# Hawaii is unique: single statewide district with ~290 schools organized into
# 15 Complex Areas (geographic clusters centered around high schools).
#
# ==============================================================================

#' Download raw enrollment data from Hawaii sources
#'
#' Downloads school-level enrollment data from HIDOE's official sources.
#' Uses different download methods based on year:
#' - 2019+: HIDOE Excel enrollment files (falls back to DBEDT Data Book)
#' - 2011-2018: DBEDT State Data Book tables
#'
#' The end_year parameter represents the END of the school year. For example,
#' end_year=2024 requests 2023-24 school year data.
#'
#' @param end_year School year end (2023-24 = 2024)
#' @return Data frame with school-level enrollment data
#' @keywords internal
get_raw_enr <- function(end_year) {

  # Validate year against available years
  available <- get_available_years()
  if (!end_year %in% available$years) {
    stop(paste0(
      "end_year must be one of: ", paste(available$years, collapse = ", "),
      "\nNote: end_year 2012 is not available (no 2011 Data Book published)"
    ))
  }

  message(paste("Downloading Hawaii enrollment data for", end_year, "..."))

  # Determine format era and download accordingly
  # Note: detect_format_era uses Data Book year, which is end_year - 1
  db_year <- get_databook_year(end_year)
  era <- detect_format_era(db_year)

  if (era == "hidoe_modern") {
    # Modern HIDOE Excel format (db_year >= 2018, so end_year >= 2019)
    # Note: HIDOE direct download often fails, so this falls back to DBEDT
    raw_data <- download_hidoe_enrollment(end_year)
  } else if (era == "dbedt_recent") {
    # DBEDT Data Book format (db_year 2010-2017, so end_year 2011-2018)
    raw_data <- download_dbedt_enrollment(end_year)
  } else {
    stop(paste("Data not available for year", end_year))
  }

  # Ensure end_year column exists (may already be added by process_dbedt_tables)
  if (!"end_year" %in% names(raw_data)) {
    raw_data$end_year <- end_year
  }

  raw_data
}


#' Download HIDOE official enrollment data (2018+)
#'
#' Downloads enrollment data from the Hawaii DOE website.
#' Files are Excel format with school-level enrollment by grade and type.
#'
#' @param end_year School year end (2018-2025)
#' @return Data frame with enrollment data
#' @keywords internal
download_hidoe_enrollment <- function(end_year) {

  message("  Downloading from HIDOE...")


  # Construct the school year string (e.g., "2022-23" for end_year 2023)
  start_year <- end_year - 1
  sy_short <- paste0(start_year, "-", substr(end_year, 3, 4))

  # HIDOE enrollment files follow pattern:
  # https://www.hawaiipublicschools.org/DOE%20Forms/Enrollment/HIDOEenrollment{YYYY-YY}.xlsx
  # But this may not be reliable, so we try multiple URL patterns

  # Try the direct Excel URL first
  url_patterns <- c(
    paste0("https://www.hawaiipublicschools.org/DOE%20Forms/Enrollment/HIDOEenrollment", sy_short, ".xlsx"),
    paste0("https://www.hawaiipublicschools.org/DOE%20Forms/Enrollment/HIDOEEnrollment", sy_short, ".xlsx"),
    paste0("https://www.hawaiipublicschools.org/DOE%20Forms/Enrollment/Enrollment", sy_short, ".xlsx")
  )

  # Create temp file
  tname <- tempfile(
    pattern = paste0("hidoe_enr_", end_year, "_"),
    tmpdir = tempdir(),
    fileext = ".xlsx"
  )

  downloaded <- FALSE

  for (url in url_patterns) {
    tryCatch({
      response <- httr::GET(
        url,
        httr::write_disk(tname, overwrite = TRUE),
        httr::timeout(120)
      )

      if (!httr::http_error(response)) {
        # Check if we got an Excel file (not an error page)
        file_info <- file.info(tname)
        if (file_info$size > 5000) {  # Real Excel files should be > 5KB
          downloaded <- TRUE
          message(paste("  Downloaded from:", url))
          break
        }
      }
    }, error = function(e) {
      # Continue to next URL pattern
    })
  }

  if (!downloaded) {
    # Fall back to DBEDT if HIDOE direct download fails
    message("  HIDOE direct download failed, trying DBEDT Data Book...")
    return(download_dbedt_enrollment(end_year))
  }

  # Read Excel file
  # HIDOE files typically have multiple sheets or a single data sheet
  df <- tryCatch({
    # Try reading the first sheet
    readxl::read_excel(tname, sheet = 1, col_types = "text")
  }, error = function(e) {
    stop(paste("Failed to read Excel file for year", end_year, "\nError:", e$message))
  })

  # Clean up temp file
  unlink(tname)

  # Standardize column names
  df <- standardize_hidoe_columns(df)

  df
}


#' Download DBEDT State Data Book enrollment data
#'
#' Downloads enrollment data from the Hawaii DBEDT State Data Book.
#' Files are Excel tables with state-level and county-level enrollment by grade.
#'
#' Table numbers changed over time:
#' - 2010-2015: Table 3.12 has enrollment by grade and county
#' - 2016+: Table 3.13 has enrollment by grade and county
#'
#' Important: The Data Book publication year is typically one year behind the
#' school year end. For example, the 2023 Data Book contains 2023-24 school
#' year data (end_year=2024). Use get_databook_year() to map correctly.
#'
#' @param end_year School year end
#' @return Data frame with enrollment data
#' @keywords internal
download_dbedt_enrollment <- function(end_year) {

  message("  Downloading from DBEDT Data Book...")

  # Map end_year to the correct Data Book publication year
  # e.g., end_year=2024 -> db_year=2023 (2023 Data Book has 2023-24 data)
  db_year <- get_databook_year(end_year)
  yy <- substr(db_year, 3, 4)

  # Table numbers changed over time:
  # - 2010-2015: Table 3.12 = Public School Enrollment by Grade and County
  # - 2016+: Table 3.13 = Public School Enrollment by Grade and County
  # We try both and use whichever has the expected "Grade" header

  tables_to_try <- c("0313", "0312")  # Try 3.13 first (more recent years)

  enr_df <- NULL
  tname_enr <- tempfile(pattern = "dbedt_enr_", tmpdir = tempdir(), fileext = ".xls")

  for (tbl in tables_to_try) {
    url_enrollment <- paste0(
      "https://files.hawaii.gov/dbedt/economic/databook/",
      db_year, "-individual/03/", tbl, yy, ".xls"
    )

    tryCatch({
      response <- httr::GET(
        url_enrollment,
        httr::write_disk(tname_enr, overwrite = TRUE),
        httr::timeout(120)
      )

      if (!httr::http_error(response)) {
        file_info <- file.info(tname_enr)
        if (file_info$size > 1000) {
          temp_df <- readxl::read_excel(tname_enr, col_types = "text")

          # Check if this table has the expected "Grade" header
          has_grade <- any(grepl("Grade", unlist(temp_df[1:10, 1:2]), ignore.case = TRUE))
          if (has_grade) {
            enr_df <- temp_df
            message(paste("  Downloaded enrollment table from:", url_enrollment))
            break
          }
        }
      }
    }, error = function(e) {
      # Continue to next table
    })
  }

  # Clean up temp file
  unlink(tname_enr)

  # Also try to download ethnicity table (optional, for future use)
  url_ethnicity <- paste0(
    "https://files.hawaii.gov/dbedt/economic/databook/",
    db_year, "-individual/03/0319", yy, ".xls"
  )

  eth_df <- NULL
  tname_eth <- tempfile(pattern = "dbedt_eth_", tmpdir = tempdir(), fileext = ".xls")

  tryCatch({
    response <- httr::GET(
      url_ethnicity,
      httr::write_disk(tname_eth, overwrite = TRUE),
      httr::timeout(120)
    )

    if (!httr::http_error(response)) {
      file_info <- file.info(tname_eth)
      if (file_info$size > 1000) {
        eth_df <- readxl::read_excel(tname_eth, col_types = "text")
        message(paste("  Downloaded ethnicity table from:", url_ethnicity))
      }
    }
  }, error = function(e) {
    # Ethnicity table is optional
  })

  unlink(tname_eth)

  if (is.null(enr_df)) {
    stop(paste("Could not download enrollment data for year", end_year,
               "\nNo DBEDT table found with 'Grade' header in tables 3.12 or 3.13"))
  }

  # Process DBEDT tables into standard format
  df <- process_dbedt_tables(enr_df, eth_df, end_year)

  df
}


#' Standardize HIDOE column names
#'
#' Maps HIDOE column names to standardized names.
#'
#' @param df Data frame with raw HIDOE columns
#' @return Data frame with standardized column names
#' @keywords internal
standardize_hidoe_columns <- function(df) {

  # Get original column names
  orig_names <- names(df)

  # Create a lowercase version for matching
  lower_names <- tolower(orig_names)

  # Define mappings (lowercase pattern -> standard name)
  col_map <- list(
    school_code = c("school code", "schoolcode", "school_code", "code", "school #", "school number"),
    school_name = c("school name", "schoolname", "school_name", "school", "name"),
    complex_area = c("complex area", "complexarea", "complex_area", "complex", "area"),
    school_type = c("school type", "schooltype", "school_type", "type", "level"),
    total = c("total", "total enrollment", "enrollment", "all students"),
    regular_ed = c("regular education", "regular ed", "regular", "reg ed"),
    special_ed = c("special education", "special ed", "sped", "spec ed"),
    grade_pk = c("pre-k", "prek", "pk", "pre-kindergarten", "prekindergarten"),
    grade_k = c("k", "kindergarten", "kinder"),
    grade_01 = c("1", "01", "grade 1", "first", "1st"),
    grade_02 = c("2", "02", "grade 2", "second", "2nd"),
    grade_03 = c("3", "03", "grade 3", "third", "3rd"),
    grade_04 = c("4", "04", "grade 4", "fourth", "4th"),
    grade_05 = c("5", "05", "grade 5", "fifth", "5th"),
    grade_06 = c("6", "06", "grade 6", "sixth", "6th"),
    grade_07 = c("7", "07", "grade 7", "seventh", "7th"),
    grade_08 = c("8", "08", "grade 8", "eighth", "8th"),
    grade_09 = c("9", "09", "grade 9", "ninth", "9th"),
    grade_10 = c("10", "grade 10", "tenth", "10th"),
    grade_11 = c("11", "grade 11", "eleventh", "11th"),
    grade_12 = c("12", "grade 12", "twelfth", "12th")
  )

  # Apply mappings
  new_names <- orig_names
  for (std_name in names(col_map)) {
    patterns <- col_map[[std_name]]
    for (i in seq_along(lower_names)) {
      if (lower_names[i] %in% patterns) {
        new_names[i] <- std_name
        break
      }
    }
  }

  names(df) <- new_names
  df
}


#' Process DBEDT Data Book tables
#'
#' Converts DBEDT table format to standard enrollment format.
#' DBEDT provides aggregate data at state and county level, organized by grade.
#' This function parses the enrollment by grade table (Table 3.12 or 3.13
#' depending on year) and returns tidy enrollment data.
#'
#' Note: Some years (e.g., 2021) contain multiple school years in one table.
#' This function extracts only the data for the requested end_year.
#'
#' @param enr_df Enrollment by grade data frame (Table 3.12 or 3.13)
#' @param eth_df Ethnicity data frame (Table 3.19), optional
#' @param end_year School year end
#' @return Data frame in standard format with county-level enrollment by grade
#' @keywords internal
process_dbedt_tables <- function(enr_df, eth_df, end_year) {

  if (is.null(enr_df)) {
    stop("No enrollment data available for year ", end_year)
  }

  # Find the header row - must contain county names (State, Honolulu, Hawaii, etc.)
  # Look for row with "State" and other geographic columns
  header_row <- NULL
  for (i in 1:min(10, nrow(enr_df))) {
    row_text <- paste(unlist(enr_df[i, ]), collapse = " ")
    # Header row must contain both "State" and at least one county
    has_state <- grepl("State", row_text, ignore.case = TRUE)
    has_county <- grepl("Honolulu|Hawaii|Maui|Kauai", row_text, ignore.case = TRUE)
    if (has_state && has_county) {
      header_row <- i
      break
    }
  }

  if (is.null(header_row)) {
    stop("Could not find header row in enrollment table for year ", end_year,
         "\nExpected row with 'State' and county names (Honolulu, Hawaii, Maui, Kauai)")
  }

  # Extract headers from the header row
  headers <- as.character(unlist(enr_df[header_row, ]))
  headers <- trimws(headers)

  # Standardize header names
  headers <- gsub("\\s+", " ", headers)  # collapse multiple spaces
  headers[grepl("State", headers, ignore.case = TRUE)] <- "state_total"
  headers[grepl("Honolulu", headers, ignore.case = TRUE)] <- "honolulu"
  headers[grepl("Hawaii", headers, ignore.case = TRUE) &
          !grepl("State", headers, ignore.case = TRUE)] <- "hawaii_county"
  headers[grepl("Maui", headers, ignore.case = TRUE)] <- "maui"
  headers[grepl("Kauai", headers, ignore.case = TRUE)] <- "kauai"
  headers[grepl("Charter", headers, ignore.case = TRUE)] <- "charter_schools"
  headers[1] <- "grade"

  names(enr_df) <- headers

  # Filter to data rows only (after header, before footnotes)
  data_start <- header_row + 1
  data_rows <- enr_df[(data_start):nrow(enr_df), ]

  # Remove empty rows and footnote rows
  data_rows <- data_rows[!is.na(data_rows$grade), ]
  data_rows <- data_rows[!grepl("^\\d/|^Source|^http|^accessed|^1/|^2/|^<", data_rows$grade), ]
  data_rows <- data_rows[nchar(trimws(data_rows$grade)) > 0, ]

  # Reset row indices for clean indexing
  rownames(data_rows) <- NULL

  # Handle multi-year tables (e.g., 2021 has both 2020-2021 and 2021-2022)
  # Check if there are year headers within the data
  start_year <- end_year - 1

  # Look for year markers in the grade column (format: YYYY-YY or YYYY-YYYY)
  year_rows <- grep("^[0-9]{4}-[0-9]{2,4}$", data_rows$grade)

  if (length(year_rows) > 0) {
    # Multi-year table - find the section for our target year
    target_row <- grep(paste0("^", start_year, "-"), data_rows$grade)

    if (length(target_row) > 0) {
      # Find the range for our target year
      target_start <- target_row[1]

      # Find where the next year section starts (or end of data)
      next_year_rows <- year_rows[year_rows > target_start]
      if (length(next_year_rows) > 0) {
        target_end <- next_year_rows[1] - 1
      } else {
        target_end <- nrow(data_rows)
      }

      # Extract just this section
      data_rows <- data_rows[target_start:target_end, ]

      # The first row is the year header with total, treat it as TOTAL grade
      if (nrow(data_rows) > 0 && grepl("^[0-9]{4}-", data_rows$grade[1])) {
        data_rows$grade[1] <- "TOTAL"
      }
    }
  }

  # Standardize grade names
  data_rows$grade <- trimws(data_rows$grade)
  data_rows$grade <- gsub("All grades", "TOTAL", data_rows$grade, ignore.case = TRUE)
  data_rows$grade <- gsub("^Total$", "TOTAL", data_rows$grade, ignore.case = TRUE)
  data_rows$grade <- gsub("Pre-Kindergarten|Nursery|Pre-K", "PK", data_rows$grade, ignore.case = TRUE)
  data_rows$grade <- gsub("^Kindergarten$", "K", data_rows$grade, ignore.case = TRUE)
  data_rows$grade <- gsub("Special Ed\\.|Special Education", "SPED", data_rows$grade, ignore.case = TRUE)

  # Convert single-digit grade numbers to standard format (01, 02, etc.)
  is_single_digit <- grepl("^[1-9]$", data_rows$grade)
  data_rows$grade[is_single_digit] <- sprintf(
    "%02d",
    as.integer(data_rows$grade[is_single_digit])
  )

  # Pivot to long format - one row per county/grade combination
  county_cols <- c("state_total", "honolulu", "hawaii_county", "maui", "kauai", "charter_schools")
  county_cols <- intersect(county_cols, names(data_rows))

  # Build result data frame
  result_list <- list()

  for (county in county_cols) {
    if (county %in% names(data_rows)) {
      county_data <- data.frame(
        county_name = county,
        grade = data_rows$grade,
        enrollment = safe_numeric(data_rows[[county]]),
        stringsAsFactors = FALSE
      )
      result_list[[county]] <- county_data
    }
  }

  result <- do.call(rbind, result_list)
  rownames(result) <- NULL

  # Add metadata
  result$end_year <- end_year

  # Standardize county names for display
  result$county_name <- dplyr::case_when(
    result$county_name == "state_total" ~ "State Total",
    result$county_name == "honolulu" ~ "Honolulu",
    result$county_name == "hawaii_county" ~ "Hawaii County",
    result$county_name == "maui" ~ "Maui",
    result$county_name == "kauai" ~ "Kauai",
    result$county_name == "charter_schools" ~ "Charter Schools",
    TRUE ~ result$county_name
  )

  # Add aggregation level indicator
  result$agg_level <- ifelse(
    result$county_name == "State Total",
    "STATE",
    ifelse(result$county_name == "Charter Schools", "CHARTER", "COUNTY")
  )

  # Reorder columns
  result <- result[, c("end_year", "agg_level", "county_name", "grade", "enrollment")]

  # Remove rows with NA enrollment (footnote markers like "(1/)")
  result <- result[!is.na(result$enrollment), ]

  result
}


#' Get HIDOE enrollment URL for a specific year
#'
#' Returns the URL for downloading HIDOE enrollment data.
#'
#' @param end_year School year end
#' @return URL string
#' @keywords internal
get_hidoe_url <- function(end_year) {
  start_year <- end_year - 1
  sy_short <- paste0(start_year, "-", substr(end_year, 3, 4))
  paste0("https://www.hawaiipublicschools.org/DOE%20Forms/Enrollment/HIDOEenrollment", sy_short, ".xlsx")
}
