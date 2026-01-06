# ==============================================================================
# Enrollment Data Fetching Functions
# ==============================================================================
#
# This file contains the main user-facing functions for fetching Hawaii
# enrollment data from the Hawaii Department of Education (HIDOE).
#
# ==============================================================================

#' Fetch Hawaii enrollment data
#'
#' Downloads and returns enrollment data from the Hawaii Department of
#' Education (HIDOE) via the DBEDT State Data Book.
#'
#' The end_year parameter uses the standard convention: it represents the
#' END of the school year. For example:
#' - end_year = 2024 returns data for the 2023-24 school year
#' - end_year = 2025 returns data for the 2024-25 school year
#'
#' @param end_year School year end (2023-24 = 2024). See get_available_years()
#'   for the range of available years.
#' @param tidy If TRUE (default), returns data in long (tidy) format with subgroup
#'   column. If FALSE, returns wide format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return Data frame with enrollment data by county and grade
#' @export
#' @examples
#' \dontrun{
#' # Get 2024 enrollment data (2023-24 school year)
#' enr_2024 <- fetch_enr(2024)
#'
#' # Get 2025 enrollment data (2024-25 school year)
#' enr_2025 <- fetch_enr(2025)
#'
#' # Force fresh download
#' enr_fresh <- fetch_enr(2024, use_cache = FALSE)
#' }
fetch_enr <- function(end_year, tidy = TRUE, use_cache = TRUE) {

  # Validate year - check against actual available years list
  available <- get_available_years()
  if (!end_year %in% available$years) {
    stop(paste0(
      "end_year must be one of: ", paste(available$years, collapse = ", "),
      "\nNote: end_year 2012 is not available (no 2011 Data Book published).",
      "\nUse get_available_years() for details on data availability."
    ))
  }

  # Check cache first
  if (use_cache && cache_exists(end_year, "enrollment")) {
    message(paste("Using cached data for", end_year))
    cached_data <- read_cache(end_year, "enrollment")
    # Apply tidy transformation if requested and data isn't already tidy
    if (tidy && !"subgroup" %in% names(cached_data)) {
      cached_data <- tidy_enr(cached_data)
    }
    return(cached_data)
  }

  # Get raw data
  raw <- get_raw_enr(end_year)

  # Extract from list if needed
  if (is.list(raw) && !is.data.frame(raw)) {
    if ("enrollment" %in% names(raw)) {
      result <- raw$enrollment
    } else if ("district" %in% names(raw)) {
      result <- raw$district
    } else {
      result <- raw[[1]]
    }
  } else {
    result <- raw
  }

  # Apply tidy transformation if requested
  if (tidy) {
    result <- tidy_enr(result)
  }

  # Cache the result
  if (use_cache) {
    write_cache(result, end_year, "enrollment")
  }

  result
}


#' Fetch enrollment data for multiple years
#'
#' Downloads and combines enrollment data for multiple school years.
#'
#' @param end_years Vector of school year ends (e.g., c(2022, 2023, 2024))
#' @param tidy If TRUE (default), returns data in long (tidy) format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return Combined data frame with enrollment data for all requested years
#' @export
#' @examples
#' \dontrun{
#' # Get 3 years of data
#' enr_multi <- fetch_enr_multi(2023:2025)
#' }
fetch_enr_multi <- function(end_years, tidy = TRUE, use_cache = TRUE) {

  # Validate years against available years
  available <- get_available_years()
  invalid_years <- end_years[!end_years %in% available$years]
  if (length(invalid_years) > 0) {
    stop(paste0(
      "Invalid years: ", paste(invalid_years, collapse = ", "),
      "\nAvailable years: ", paste(available$years, collapse = ", ")
    ))
  }

  # Fetch each year
  results <- purrr::map(
    end_years,
    function(yr) {
      message(paste("Fetching", yr, "..."))
      fetch_enr(yr, tidy = tidy, use_cache = use_cache)
    }
  )

  # Combine
  dplyr::bind_rows(results)
}
