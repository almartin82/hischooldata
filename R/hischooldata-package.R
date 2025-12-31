#' hischooldata: Fetch and Process Hawaii School Data
#'
#' Downloads and processes school data from the Hawaii Department of Education
#' (HIDOE). Provides functions for fetching enrollment data and transforming
#' it into tidy format for analysis.
#'
#' @section Hawaii's Unique Structure:
#' Hawaii is the only U.S. state with a single statewide school district.
#' The Hawaii Department of Education (HIDOE) operates all public schools
#' directly, organized into 15 Complex Areas (geographic clusters of schools).
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{fetch_enr}}}{Fetch enrollment data for a school year}
#'   \item{\code{\link{fetch_enr_multi}}}{Fetch enrollment data for multiple years}
#'   \item{\code{\link{tidy_enr}}}{Transform wide data to tidy (long) format}
#'   \item{\code{\link{id_enr_aggs}}}{Add aggregation level flags}
#'   \item{\code{\link{enr_grade_aggs}}}{Create grade-level aggregations}
#' }
#'
#' @section Cache functions:
#' \describe{
#'   \item{\code{\link{cache_status}}}{View cached data files}
#'   \item{\code{\link{clear_cache}}}{Remove cached data files}
#' }
#'
#' @section ID System:
#' Hawaii uses a school-based system with state school codes:
#' \itemize{
#'   \item District ID: Always "001" (single statewide district)
#'   \item Campus/School IDs: 3-digit codes assigned by HIDOE
#'   \item Complex Areas: 15 geographic groupings of schools
#' }
#'
#' @section Demographics:
#' Hawaii has unique demographics compared to mainland states:
#' \itemize{
#'   \item Majority Asian and Pacific Islander population
#'   \item Native Hawaiian is a significant demographic category
#'   \item Part-Hawaiian is tracked separately from Native Hawaiian
#'   \item Filipino is the largest single ethnic group in many schools
#' }
#'
#' @section Data Sources:
#' Data is sourced from the Hawaii Department of Education:
#' \itemize{
#'   \item HIDOE: \url{https://www.hawaiipublicschools.org/}
#'   \item School Reports: \url{https://hawaiipublicschools.org/data-reports/school-reports/}
#'   \item ARCH: \url{https://arch.k12.hi.us/}
#' }
#'
#' @docType package
#' @name hischooldata-package
#' @aliases hischooldata
#' @keywords internal
"_PACKAGE"

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL
