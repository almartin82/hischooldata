#' hischooldata: Fetch and Process Hawaii School Data
#'
#' Downloads and processes school data from the Hawaii Department of Education
#' (HIDOE) via the DBEDT State Data Book. Provides functions for fetching
#' enrollment data in tidy format for analysis.
#'
#' @section Hawaii's Unique Structure:
#' Hawaii is the only U.S. state with a single statewide school district.
#' The Hawaii Department of Education (HIDOE) operates all public schools
#' directly. Data is organized by county (Honolulu, Hawaii County, Maui,
#' Kauai) and Charter Schools.
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{fetch_enr}}}{Fetch enrollment data for a school year}
#'   \item{\code{\link{fetch_enr_multi}}}{Fetch enrollment data for multiple years}
#'   \item{\code{\link{get_available_years}}}{List available school years}
#' }
#'
#' @section Cache functions:
#' \describe{
#'   \item{\code{\link{cache_status}}}{View cached data files}
#'   \item{\code{\link{clear_cache}}}{Remove cached data files}
#' }
#'
#' @section end_year Convention:
#' The end_year parameter represents the END of the school year:
#' \itemize{
#'   \item end_year = 2024 means the 2023-24 school year
#'   \item end_year = 2025 means the 2024-25 school year
#' }
#'
#' @section Data Sources:
#' Data is sourced from the DBEDT State Data Book:
#' \itemize{
#'   \item DBEDT Data Book: \url{https://files.hawaii.gov/dbedt/economic/databook/}
#'   \item HIDOE: \url{https://www.hawaiipublicschools.org/}
#' }
#'
#' @docType package
#' @name hischooldata-package
#' @aliases hischooldata
#' @keywords internal
"_PACKAGE"

