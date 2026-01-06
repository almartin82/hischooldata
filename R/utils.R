# ==============================================================================
# Utility Functions
# ==============================================================================

#' @importFrom rlang .data
#' @importFrom magrittr %>%
NULL


#' Convert to numeric, handling suppression markers
#'
#' HIDOE uses various markers for suppressed data (*, <5, -, etc.)
#' and may use commas in large numbers.
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric <- function(x) {
  # Remove commas and whitespace
  x <- gsub(",", "", x)
  x <- trimws(x)

  # Handle common suppression markers
  x[x %in% c("*", ".", "-", "-1", "<5", "N/A", "NA", "", "n/a")] <- NA_character_

  suppressWarnings(as.numeric(x))
}


#' Clean school names
#'
#' Standardizes school names by trimming whitespace and fixing common issues.
#'
#' @param x Character vector of school names
#' @return Cleaned character vector
#' @keywords internal
clean_school_name <- function(x) {
  x <- trimws(x)
  # Remove extra whitespace
  x <- gsub("\\s+", " ", x)
  # Standardize Hawaiian okina (glottal stop)
  x <- gsub("'", "\u02BB", x)  # Replace straight quote with proper okina
  x
}


#' Get Hawaii Complex Area from school
#'
#' Maps schools to their Complex Area (geographic grouping).
#' Hawaii has 15 Complex Areas organized around high schools.
#'
#' @param school_code Character vector of school codes
#' @return Character vector of Complex Area names
#' @keywords internal
get_complex_area <- function(school_code) {
  # This would require a lookup table; returning NA for now

  # Complex Areas: Aiea-Moanalua-Radford, Campbell-Kapolei, Castle-Kahuku,

  # Farrington-Kaiser-Kalani, Kailua-Kalaheo, Kaimuki-McKinley-Roosevelt,
  # Leilehua-Mililani-Waialua, Pearl City-Waipahu, Baldwin-Kekaulike-Maui,
  # Hana-Lahainaluna-Lanai-Molokai, Hawaii, Honokaa-Kealakehe-Kohala-Konawaena,
  # Ka'u-Keaau-Pahoa, Hilo-Laupahoehoe-Waiakea, Kapaa-Kauai-Waimea
  rep(NA_character_, length(school_code))
}


#' Detect format era for Hawaii data
#'
#' Hawaii data comes in different formats depending on the year:
#' - Era 1 (2018+): Modern HIDOE Excel format
#' - Era 2 (2010-2017): DBEDT Data Book format
#' - Era 3 (pre-2010): Historical DBEDT format
#'
#' @param end_year School year end
#' @return Character string indicating format era
#' @keywords internal
detect_format_era <- function(end_year) {
  if (end_year >= 2018) {
    return("hidoe_modern")
  } else if (end_year >= 2010) {
    return("dbedt_recent")
  } else {
    return("dbedt_historical")
  }
}


#' Get available years for Hawaii enrollment data
#'
#' Returns the range of years for which enrollment data can be fetched
#' from the Hawaii Department of Education via DBEDT Data Book.
#'
#' The `end_year` parameter follows the convention that it represents the
#' END year of the school year. For example:
#' - end_year = 2024 means the 2023-24 school year (ending June 2024)
#' - end_year = 2025 means the 2024-25 school year (ending June 2025)
#'
#' Note on data sources: DBEDT Data Books are published annually and typically
#' contain enrollment data for the school year that ends in that publication year.
#' For example, the 2023 Data Book contains 2023-24 school year data (end_year=2024).
#'
#' Known gaps:
#' - end_year 2012 is not available (no 2011 Data Book published)
#' - end_year 2020 appears in both 2019 and 2020 Data Books (COVID impact)
#'
#' @return A list with components:
#'   \describe{
#'     \item{min_year}{Earliest available year (2011)}
#'     \item{max_year}{Most recent available year (2025)}
#'     \item{years}{Vector of all available years}
#'     \item{description}{Human-readable description of the date range}
#'   }
#' @export
#' @examples
#' get_available_years()
get_available_years <- function() {
  # Available end_years based on Data Book -> school year mapping:
  # - 2010 Data Book -> 2010-2011 school year -> end_year 2011
  # - 2012 Data Book -> 2012-2013 school year -> end_year 2013
  # - 2013-2024 Data Books -> respective school years
  # Note: end_year 2012 is NOT available (no 2011 Data Book)
  available <- c(2011, 2013:2025)

  list(
    min_year = min(available),
    max_year = max(available),
    years = available,
    description = paste0(
      "Hawaii enrollment data is available for school years ending 2011 to 2025 ",
      "(except 2012 - no 2011 Data Book published)"
    )
  )
}


#' Map end_year to Data Book year
#'
#' Internal function to map the requested end_year to the correct
#' DBEDT Data Book publication year.
#'
#' The mapping handles several special cases:
#' - 2020 Data Book has 2019-20 data (duplicate of 2019 Data Book)
#' - 2021 Data Book has BOTH 2020-21 AND 2021-22 data
#'
#' @param end_year School year end (e.g., 2024 for 2023-24 school year)
#' @return Data Book year to fetch from
#' @keywords internal
get_databook_year <- function(end_year) {
  # Data Book year = end_year - 1 for most cases
  db_year <- end_year - 1

  # Special cases:
  # - end_year=2020 (2019-20): Use 2019 Data Book (2020 is duplicate)
  # - end_year=2021 (2020-21): Use 2021 Data Book (has both 2020-21 and 2021-22)
  # - end_year=2022 (2021-22): Use 2021 Data Book (has both 2020-21 and 2021-22)
  if (end_year == 2020) {
    db_year <- 2019  # 2020 Data Book is duplicate of 2019
  } else if (end_year == 2021) {
    db_year <- 2021  # 2021 Data Book has 2020-21 data in multi-year table
  }
  # Note: end_year=2022 already maps to db_year=2021 via the default formula

  db_year
}
