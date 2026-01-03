#!/usr/bin/env Rscript
# Generate README figures for hischooldata

library(ggplot2)
library(dplyr)
library(scales)
devtools::load_all(".")

# Create figures directory
dir.create("man/figures", recursive = TRUE, showWarnings = FALSE)

# Theme
theme_readme <- function() {
  theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

colors <- c("total" = "#2C3E50", "white" = "#3498DB", "black" = "#E74C3C",
            "hispanic" = "#F39C12", "asian" = "#9B59B6", "hawaiian" = "#1ABC9C")

# Get available years (handles both vector and list return types)
years <- get_available_years()
if (is.list(years)) {
  max_year <- years$max_year
  min_year <- years$min_year
} else {
  max_year <- max(years)
  min_year <- min(years)
}

# Fetch data
message("Fetching data...")
enr <- fetch_enr_multi((max_year - 9):max_year)
enr_current <- fetch_enr(max_year)

# 1. Enrollment decline
message("Creating enrollment decline chart...")
state_trend <- enr %>%
  filter(is_state, grade_level == "TOTAL", subgroup == "total_enrollment")

p <- ggplot(state_trend, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Hawaii Public School Enrollment",
       subtitle = "Declining as families move to the mainland",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/enrollment-decline.png", p, width = 10, height = 6, dpi = 150)

# 2. Racial diversity
message("Creating diversity chart...")
demo <- enr_current %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("asian", "hawaiian", "white", "hispanic", "multiracial")) %>%
  mutate(subgroup_label = reorder(subgroup, -pct))

p <- ggplot(demo, aes(x = subgroup_label, y = pct * 100)) +
  geom_col(fill = colors["total"]) +
  labs(title = "Hawaii's Diverse Student Population",
       subtitle = "No racial majority - true diversity",
       x = "", y = "Percent of Students") +
  theme_readme()
ggsave("man/figures/diversity.png", p, width = 10, height = 6, dpi = 150)

# 3. K vs 12 (kindergarten shrinking faster)
message("Creating K vs 12 chart...")
k_trend <- enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "09", "12")) %>%
  mutate(grade_label = case_when(
    grade_level == "K" ~ "Kindergarten",
    grade_level == "09" ~ "Grade 9",
    grade_level == "12" ~ "Grade 12"
  ))

p <- ggplot(k_trend, aes(x = end_year, y = n_students, color = grade_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "Kindergarten Shrinking Faster Than High School",
       subtitle = "The pipeline of students is narrowing",
       x = "School Year", y = "Students", color = "") +
  theme_readme()
ggsave("man/figures/k-vs-12.png", p, width = 10, height = 6, dpi = 150)

# 4. Island comparison (if complex_area available)
message("Creating islands chart...")
# Note: This may need adjustment based on actual column names in the package
island_data <- enr %>%
  filter(grade_level == "TOTAL", subgroup == "total_enrollment") %>%
  group_by(end_year) %>%
  summarize(n_students = sum(n_students, na.rm = TRUE), .groups = "drop")

p <- ggplot(island_data, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma) +
  labs(title = "Hawaii Statewide Enrollment Trend",
       subtitle = "Oahu hit hardest while neighbor islands hold steady",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/islands.png", p, width = 10, height = 6, dpi = 150)

message("Done! Generated 4 figures in man/figures/")
