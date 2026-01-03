# Detect format era for Hawaii data

Hawaii data comes in different formats depending on the year:

- Era 1 (2018+): Modern HIDOE Excel format

- Era 2 (2010-2017): DBEDT Data Book format

- Era 3 (pre-2010): Historical DBEDT format

## Usage

``` r
detect_format_era(end_year)
```

## Arguments

- end_year:

  School year end

## Value

Character string indicating format era
