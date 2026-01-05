# ==============================================================================
# Tidy Format Transformation Functions
# ==============================================================================
#
# This file contains functions for transforming raw enrollment data
# into the standard tidy format used across all {state}schooldata packages.
#
# ==============================================================================

#' Transform enrollment data to tidy format
#'
#' Converts raw/semi-tidy Hawaii enrollment data into the standard tidy format
#' used across all state schooldata packages.
#'
#' The tidy format has one row per (entity, grade_level, subgroup) combination,
#' making it easy to filter, group, and analyze.
#'
#' @param df Data frame with raw enrollment data (from get_raw_enr())
#' @return Data frame in standard tidy format with columns:
#'   \describe{
#'     \item{end_year}{School year end (2024 = 2023-24 school year)}
#'     \item{district_id}{State identifier (HI for Hawaii - single district state)}
#'     \item{district_name}{District name (Hawaii Department of Education)}
#'     \item{county_name}{County name (Honolulu, Hawaii County, Maui, Kauai, State Total, Charter Schools)}
#'     \item{type}{Aggregation level (STATE, COUNTY, CHARTER)}
#'     \item{grade_level}{Grade level (TOTAL, PK, K, 01-12, SPED)}
#'     \item{subgroup}{Demographic subgroup (only "total_enrollment" available)}
#'     \item{n_students}{Student count}
#'     \item{pct}{Percentage (NA for Hawaii - no demographic data)}
#'     \item{aggregation_flag}{Aggregation level ("state" or "district")}
#'     \item{is_state}{Logical TRUE for state-level rows}
#'     \item{is_county}{Logical TRUE for county-level rows}
#'     \item{is_charter}{Logical TRUE for charter school aggregate rows}
#'   }
#' @keywords internal
tidy_enr <- function(df) {

  # Check if already tidy
  if ("subgroup" %in% names(df) && "n_students" %in% names(df)) {
    return(df)
  }

  # Start with raw format from process_dbedt_tables()
  # Columns: end_year, agg_level, county_name, grade, enrollment

  # Rename columns to standard
  result <- df %>%
    dplyr::rename(
      grade_level = grade,
      n_students = enrollment,
      type = agg_level
    )

  # Add subgroup column (Hawaii only has total enrollment, no demographic breakdowns)
  result$subgroup <- "total_enrollment"

  # Add pct column (all NA since no subgroup data to calculate percentages)
  result$pct <- NA_real_

  # Add identifier columns (Hawaii is a single statewide district)
  result$district_id <- "HI"
  result$district_name <- "Hawaii Department of Education"

  # Add boolean indicators for filtering
  result$is_state <- result$type == "STATE"
  result$is_county <- result$type == "COUNTY"
  result$is_charter <- result$type == "CHARTER"

  # Add aggregation_flag column (required by PRD)
  # Hawaii has no campus_id, so aggregation is either state or district level
  result$aggregation_flag <- dplyr::case_when(
    result$type == "STATE" ~ "state",
    TRUE ~ "district"
  )

  # Reorder columns to match standard format
  # Standard order: end_year, district_id, district_name, county_name, type,
  #                 grade_level, subgroup, n_students, pct, aggregation_flag, is_*
  result <- result %>%
    dplyr::select(
      end_year,
      district_id,
      district_name,
      county_name,
      type,
      grade_level,
      subgroup,
      n_students,
      pct,
      aggregation_flag,
      is_state,
      is_county,
      is_charter
    )

  result
}
