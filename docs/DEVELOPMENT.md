# Development Notes

## README Best Practices

### Package Description

The standard description for all 50 state packages is: \> A simple,
consistent interface for accessing state-published school data in Python
and R.

This should appear: 1. In the README under “Part of the State Schooldata
Project” 2. In the GitHub repo “About” description (set via
`gh repo edit --description`)

### Show Data Output

READMEs should **show actual data output**, not just code. Users want to
see what they’ll get.

Bad:

``` r
enr_2024 <- fetch_enr(2024)
enr_2024 %>% filter(is_state) %>% select(n_students)
```

Good:

``` r
enr_2024 <- fetch_enr(2024)
enr_2024 %>% filter(is_state) %>% select(n_students)
#> # A tibble: 1 × 1
#>   n_students
#>        <int>
#> 1     179896
```

Keep output to 10 rows max. The point is to show the data is real and
useful.

## Known Issues

### Data Download Failing (2024-01)

The HIDOE direct download URLs are not working, and DBEDT Data Book
downloads are timing out. Need to: 1. Find updated HIDOE enrollment file
URLs 2. Increase timeout for DBEDT downloads 3. Add fallback/mirror
sources

## Propagating Changes

To apply a fix across all 50 packages, use:

    /school-fix

This launches parallel agents to apply, commit, push, and update all
packages.
