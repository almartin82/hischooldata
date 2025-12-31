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
#' - 2018+: HIDOE Excel enrollment files
#' - 2010-2017: DBEDT State Data Book tables
#' - Pre-2010: Historical DBEDT format
#'
#' @param end_year School year end (2023-24 = 2024)
#' @return Data frame with school-level enrollment data
#' @keywords internal
get_raw_enr <- function(end_year) {

  # Validate year - HIDOE data available from ~2010 to present
  if (end_year < 2010 || end_year > 2025) {
    stop("end_year must be between 2010 and 2025")
  }

  message(paste("Downloading Hawaii enrollment data for", end_year, "..."))

  # Determine format era and download accordingly
  era <- detect_format_era(end_year)

  if (era == "hidoe_modern") {
    # Modern HIDOE Excel format (2018+)
    raw_data <- download_hidoe_enrollment(end_year)
  } else if (era == "dbedt_recent") {
    # DBEDT Data Book format (2010-2017)
    raw_data <- download_dbedt_enrollment(end_year)
  } else {
    stop(paste("Data not available for year", end_year))
  }

  # Add end_year column
  raw_data$end_year <- end_year

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


#' Download DBEDT State Data Book enrollment data (2010-2017)
#'
#' Downloads enrollment data from the Hawaii DBEDT State Data Book.
#' Files are Excel tables with state-level and county-level enrollment.
#'
#' @param end_year School year end (2010-2017)
#' @return Data frame with enrollment data
#' @keywords internal
download_dbedt_enrollment <- function(end_year) {

  message("  Downloading from DBEDT Data Book...")

  # DBEDT Data Book tables use calendar year (publication year)
  # For school year 2016-17 (end_year 2017), look at Data Book 2017 or 2018
  db_year <- end_year

  # Table 3.13 = Public School Enrollment by Grade and County
  # Table 3.19 = Ethnicity of Public School Students
  # URL pattern: https://files.hawaii.gov/dbedt/economic/databook/{YEAR}-individual/03/0313{YY}.xls

  yy <- substr(db_year, 3, 4)

  # Try enrollment by grade table first
  url_enrollment <- paste0(
    "https://files.hawaii.gov/dbedt/economic/databook/",
    db_year, "-individual/03/0313", yy, ".xls"
  )

  # Also try ethnicity table
  url_ethnicity <- paste0(
    "https://files.hawaii.gov/dbedt/economic/databook/",
    db_year, "-individual/03/0319", yy, ".xls"
  )

  # Create temp files
  tname_enr <- tempfile(pattern = "dbedt_enr_", tmpdir = tempdir(), fileext = ".xls")
  tname_eth <- tempfile(pattern = "dbedt_eth_", tmpdir = tempdir(), fileext = ".xls")

  # Download enrollment table
  enr_df <- NULL
  tryCatch({
    response <- httr::GET(
      url_enrollment,
      httr::write_disk(tname_enr, overwrite = TRUE),
      httr::timeout(120)
    )

    if (!httr::http_error(response)) {
      file_info <- file.info(tname_enr)
      if (file_info$size > 1000) {
        enr_df <- readxl::read_excel(tname_enr, col_types = "text")
        message(paste("  Downloaded enrollment table from:", url_enrollment))
      }
    }
  }, error = function(e) {
    message(paste("  Could not download enrollment table:", e$message))
  })

  # Download ethnicity table
  eth_df <- NULL
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
    message(paste("  Could not download ethnicity table:", e$message))
  })

  # Clean up temp files
  unlink(tname_enr)
  unlink(tname_eth)

  if (is.null(enr_df) && is.null(eth_df)) {
    stop(paste("Could not download any DBEDT data for year", end_year))
  }

  # Process DBEDT tables into standard format
  # DBEDT tables have a different structure - aggregate data by county/state
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
#' DBEDT provides aggregate data (state/county level), not school-level.
#'
#' @param enr_df Enrollment by grade data frame (Table 3.13)
#' @param eth_df Ethnicity data frame (Table 3.19)
#' @param end_year School year end
#' @return Data frame in standard format
#' @keywords internal
process_dbedt_tables <- function(enr_df, eth_df, end_year) {

  # DBEDT tables are aggregate (state level), not school level
 # We create a single "state" row with available data

  result <- data.frame(
    school_code = "STATE",
    school_name = "Hawaii State Total",
    school_type = "State",
    complex_area = NA_character_,
    stringsAsFactors = FALSE
  )

  # Try to extract totals from enrollment table
  if (!is.null(enr_df)) {
    # DBEDT tables have the total in specific cells
    # The structure varies but typically has State total row
    # For now, return a placeholder that will be filled by process_enr
    result$total <- NA_integer_
  }

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
