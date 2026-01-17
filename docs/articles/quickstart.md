# Getting Started with hischooldata

## Introduction

`hischooldata` provides a simple, consistent interface for accessing
Hawaii school enrollment data from the Hawaii Department of Education
(HIDOE) via the DBEDT State Data Book.

## Installation

``` r
# Install from GitHub
remotes::install_github("almartin82/hischooldata")
```

## Quick Start

### Fetch Enrollment Data

The main function is
[`fetch_enr()`](https://almartin82.github.io/hischooldata/reference/fetch_enr.md)
which downloads enrollment data for a specific school year.

``` r
library(hischooldata)
library(dplyr)

# Fetch 2024 enrollment data (2023-24 school year)
enr <- fetch_enr(2024, use_cache = TRUE)

# View the structure
glimpse(enr)
```

    ## Rows: 90
    ## Columns: 13
    ## $ end_year         <dbl> 2024, 2024, 2024, 2024, 2024, 2024, 2024, 2024, 2024,…
    ## $ district_id      <chr> "HI", "HI", "HI", "HI", "HI", "HI", "HI", "HI", "HI",…
    ## $ district_name    <chr> "Hawaii Department of Education", "Hawaii Department …
    ## $ county_name      <chr> "State Total", "State Total", "State Total", "State T…
    ## $ type             <chr> "STATE", "STATE", "STATE", "STATE", "STATE", "STATE",…
    ## $ grade_level      <chr> "TOTAL", "PK", "K", "01", "02", "03", "04", "05", "06…
    ## $ subgroup         <chr> "total_enrollment", "total_enrollment", "total_enroll…
    ## $ n_students       <dbl> 169308, 1659, 11963, 13060, 13300, 12869, 13456, 1381…
    ## $ pct              <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ aggregation_flag <chr> "state", "state", "state", "state", "state", "state",…
    ## $ is_state         <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
    ## $ is_county        <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS…
    ## $ is_charter       <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS…

### Available Years

Check which years are available:

``` r
get_available_years()
```

    ## $min_year
    ## [1] 2011
    ## 
    ## $max_year
    ## [1] 2025
    ## 
    ## $years
    ##  [1] 2011 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025
    ## 
    ## $description
    ## [1] "Hawaii enrollment data is available for school years ending 2011 to 2025 (except 2012 - no 2011 Data Book published)"

### Multi-Year Data

Fetch data for multiple years at once:

``` r
# Fetch 3 years of data
enr_multi <- fetch_enr_multi(2022:2024, use_cache = TRUE)

# Count rows per year
enr_multi %>%
  count(end_year)
```

    ##   end_year  n
    ## 1     2022 96
    ## 2     2023 96
    ## 3     2024 90

### Data by County

Hawaii has four counties: Hawaii, Honolulu, Kauai, and Maui:

``` r
enr %>%
  filter(type == "COUNTY", grade_level == "TOTAL") %>%
  select(county_name, n_students) %>%
  arrange(desc(n_students))
```

    ##     county_name n_students
    ## 1      Honolulu     105712
    ## 2 Hawaii County      22880
    ## 3          Maui      19541
    ## 4         Kauai       8729

## Cache Management

The package caches downloaded data to speed up repeated fetches:

``` r
# View cached files
cache_status()

# Clear all cache
clear_cache()

# Clear specific year
clear_cache(2024)
```

## Session Info

``` r
sessionInfo()
```

    ## R version 4.5.0 (2025-04-11)
    ## Platform: aarch64-apple-darwin22.6.0
    ## Running under: macOS 26.1
    ## 
    ## Matrix products: default
    ## BLAS:   /opt/homebrew/Cellar/openblas/0.3.30/lib/libopenblasp-r0.3.30.dylib 
    ## LAPACK: /opt/homebrew/Cellar/r/4.5.0/lib/R/lib/libRlapack.dylib;  LAPACK version 3.12.1
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## time zone: America/New_York
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] dplyr_1.1.4        hischooldata_0.1.0
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] vctrs_0.7.0       cli_3.6.5         knitr_1.51        rlang_1.1.7      
    ##  [5] xfun_0.55         otel_0.2.0        generics_0.1.4    textshaping_1.0.4
    ##  [9] jsonlite_2.0.0    glue_1.8.0        htmltools_0.5.9   ragg_1.5.0       
    ## [13] sass_0.4.10       rmarkdown_2.30    tibble_3.3.1      evaluate_1.0.5   
    ## [17] jquerylib_0.1.4   fastmap_1.2.0     yaml_2.3.12       lifecycle_1.0.5  
    ## [21] compiler_4.5.0    codetools_0.2-20  fs_1.6.6          pkgconfig_2.0.3  
    ## [25] htmlwidgets_1.6.4 systemfonts_1.3.1 digest_0.6.39     R6_2.6.1         
    ## [29] tidyselect_1.2.1  pillar_1.11.1     magrittr_2.0.4    bslib_0.9.0      
    ## [33] withr_3.0.2       tools_4.5.0       pkgdown_2.2.0     cachem_1.1.0     
    ## [37] desc_1.4.3
