Codebook created on 2024-01-08 at 2024-01-08 13:53:39.755267
================

A codebook contains documentation and metadata describing the contents,
structure, and layout of a data file.

## Dataset description

The data contains 154260 cases and 20 variables.

## Codebook

| name                 | type    |      n | missing | unique |  mean | median |     mode | mode_value     |   sd |    v |   min |   max | range |  skew | skew_2se |  kurt | kurt_2se |
|:---------------------|:--------|-------:|--------:|-------:|------:|-------:|---------:|:---------------|-----:|-----:|------:|------:|------:|------:|---------:|------:|---------:|
| target_group         | factor  | 154260 |       0 |     11 |       |        | 15426.00 | animal hi sent |      | 0.90 |       |       |       |       |          |       |          |
| moral_concern        | integer | 154260 |       0 |      4 |  1.52 |   2.00 |     2.00 |                | 0.99 |      |  0.00 |  3.00 |  3.00 | -0.02 |    -1.61 | -1.04 |   -41.53 |
| utility              | numeric | 154260 |       0 | 154260 |  5.37 |   6.47 |     6.47 |                | 2.09 |      |  0.01 |  8.69 |  8.69 | -0.87 |   -69.67 | -0.65 |   -26.03 |
| similarity_humans    | numeric | 154260 |       0 | 154260 |  5.58 |   6.70 |     6.70 |                | 2.14 |      | -0.05 |  8.83 |  8.88 | -1.05 |   -84.19 | -0.46 |   -18.29 |
| social_status        | integer | 154260 |       0 |     10 |  5.82 |   6.00 |     6.00 |                | 1.60 |      |  1.00 | 10.00 |  9.00 | -0.21 |   -17.02 | -0.06 |    -2.49 |
| conservative_econ    | integer | 154260 |       0 |      7 |  3.49 |   4.00 |     4.00 |                | 1.49 |      |  1.00 |  7.00 |  6.00 |  0.21 |    16.85 | -0.29 |   -11.74 |
| conservative_social  | integer | 154260 |       0 |      7 |  3.00 |   3.00 |     3.00 |                | 1.70 |      |  1.00 |  7.00 |  6.00 |  0.53 |    42.39 | -0.56 |   -22.60 |
| age                  | integer | 154260 |       0 |     45 | 21.12 |  20.00 |    20.00 |                | 4.75 |      | 15.00 | 60.00 | 45.00 |  3.63 |   291.39 | 17.19 |   689.00 |
| gender               | integer | 154260 |       0 |      2 |  1.67 |   2.00 |     2.00 |                | 0.47 |      |  1.00 |  2.00 |  1.00 | -0.74 |   -59.39 | -1.45 |   -58.18 |
| country              | factor  | 154260 |       0 |     36 |       |        | 12240.00 | South Africa   |      | 0.96 |       |       |       |       |          |       |          |
| sentience            | numeric | 154260 |       0 |     30 |  5.59 |   6.05 |     6.05 |                | 1.87 |      |  1.28 |  8.33 |  7.05 | -0.90 |   -72.54 | -0.04 |    -1.45 |
| agency               | numeric | 154260 |       0 |     30 |  5.52 |   5.96 |     5.96 |                | 1.84 |      |  1.79 |  7.79 |  6.00 | -0.80 |   -64.20 | -0.49 |   -19.60 |
| soc_cog              | numeric | 154260 |       0 |     30 |  5.38 |   5.93 |     5.93 |                | 2.09 |      |  1.26 |  8.47 |  7.22 | -0.67 |   -53.87 | -0.69 |   -27.79 |
| harmfulness          | numeric | 154260 |       0 |     30 |  2.03 |   1.42 |     1.42 |                | 1.54 |      |  0.35 |  5.99 |  5.64 |  1.39 |   111.83 |  0.80 |    32.10 |
| mf_fairness          | numeric | 154260 |       0 |     13 |  3.87 |   4.00 |     4.00 |                | 0.68 |      |  1.00 |  5.00 |  4.00 | -0.56 |   -44.67 |  0.91 |    36.35 |
| mf_authority         | numeric | 154260 |       0 |     13 |  3.24 |   3.33 |     3.33 |                | 0.82 |      |  1.00 |  5.00 |  4.00 |  0.11 |     8.72 | -0.22 |    -8.97 |
| mf_loyalty           | numeric | 154260 |       0 |     13 |  2.91 |   3.00 |     3.00 |                | 0.93 |      |  1.00 |  5.00 |  4.00 |  0.20 |    16.25 | -0.43 |   -17.38 |
| mf_sanctity          | numeric | 154260 |       0 |     13 |  3.84 |   4.00 |     4.00 |                | 0.96 |      |  1.00 |  5.00 |  4.00 | -0.81 |   -65.21 |  0.15 |     5.85 |
| trust                | numeric | 154260 |       0 |     19 |  3.36 |   3.33 |     3.33 |                | 1.13 |      |  1.00 |  7.00 |  6.00 |  0.02 |     1.44 | -0.40 |   -15.85 |
| anomie_social_fabric | numeric | 154260 |       0 |     37 |  4.13 |   4.17 |     4.17 |                | 0.96 |      |  1.00 |  7.00 |  6.00 | -0.07 |    -5.27 | -0.14 |    -5.53 |

### Legend

- **Name**: Variable name
- **type**: Data type of the variable
- **missing**: Proportion of missing values for this variable
- **unique**: Number of unique values
- **mean**: Mean value
- **median**: Median value
- **mode**: Most common value (for categorical variables, this shows the
  frequency of the most common category)
- **mode_value**: For categorical variables, the value of the most
  common category
- **sd**: Standard deviation (measure of dispersion for numerical
  variables
- **v**: Agresti’s V (measure of dispersion for categorical variables)
- **min**: Minimum value
- **max**: Maximum value
- **range**: Range between minimum and maximum value
- **skew**: Skewness of the variable
- **skew_2se**: Skewness of the variable divided by 2\*SE of the
  skewness. If this is greater than abs(1), skewness is significant
- **kurt**: Kurtosis (peakedness) of the variable
- **kurt_2se**: Kurtosis of the variable divided by 2\*SE of the
  kurtosis. If this is greater than abs(1), kurtosis is significant.

This codebook was generated using the [Workflow for Open Reproducible
Code in Science (WORCS)](https://osf.io/zcvbs/)
