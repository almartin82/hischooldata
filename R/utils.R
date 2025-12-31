# ==============================================================================
# Utility Functions
# ==============================================================================

#' Pipe operator
#'
#' See \code{dplyr::\link[dplyr:reexports]{\%>\%}} for details.
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
#' - Era 3 (pre-2010): Historical DBEDT/NCES format
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
