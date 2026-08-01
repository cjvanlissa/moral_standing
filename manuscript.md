Towards a Predictive Model of Moral Concern
================
01 August, 2026

This manuscript uses the Workflow for Open Reproducible Code in Science
(Van Lissa et al. 2021) to ensure reproducibility and transparency. All
code <!--and data--> are available at
<https://github.com/cjvanlissa/moral_standing.git>.

This is an example of a non-essential citation (Van Lissa et al. 2021).
If you change the rendering function to `worcs::cite_essential`, it will
be removed.

<!--The function below inserts a notification if the manuscript is knit using synthetic data. Make sure to insert it after load_data().-->

## Results

These are the Rsquared values on training and test data (use test data
to determine unbiased performance estimates):

``` r
temp_env <- new.env()
tar_load_everything(envir = temp_env)
res <- grep("res_", ls(envir = temp_env), value = TRUE)
tab_res <- temp_env$analysis_results$rsqs
rownames(tab_res) <- NULL
knitr::kable(tab_res, digits = 2)
```

|   mse | mse_se | rsq_test | rsq_train | model  | features    |
|------:|-------:|---------:|----------:|:-------|:------------|
|  1.65 |   0.19 |     0.21 |      0.21 | lasso  | all         |
|  1.53 |   0.20 |     0.15 |      0.15 | lasso  | target      |
|  3.02 |   0.35 |     0.00 |      0.00 | lasso  | judge       |
|  3.07 |   0.35 |     0.00 |      0.00 | lasso  | demographic |
|  1.63 |   0.63 |     0.16 |      0.16 | ranger | all         |
|  1.34 |   0.59 |    -0.21 |     -0.21 | ranger | target      |
|  2.76 |   1.09 |     0.04 |      0.04 | ranger | judge       |
|  3.43 |   1.27 |     0.05 |      0.05 | ranger | demographic |
|  2.33 |   0.86 |    -0.81 |     -0.81 | tree   | all         |
|  1.83 |   0.55 |    -0.41 |     -0.41 | tree   | target      |
|  3.92 |   1.91 |    -0.67 |     -0.67 | tree   | judge       |
|  4.68 |   1.50 |    -0.36 |     -0.36 | tree   | demographic |
|  7.28 |   2.85 |    -1.28 |     -1.28 | nn     | all         |
|  1.79 |   0.53 |    -0.35 |     -0.35 | nn     | target      |
| 12.04 |   7.57 |    -0.42 |     -0.42 | nn     | judge       |
|  3.95 |   2.37 |     0.03 |      0.03 | nn     | demographic |

The best performing model (or interpretable model whose cross-validated
mean squared error was within 1SE of the best model’s cross-validated
mean squared error) is lasso.target.cvm.

### Effect of Features and Model

The variance in model performance can be broken down into components due
to model and feature set:

``` r
tab_aov <- temp_env$analysis_results$etasqs
knitr::kable(tab_aov, digits = 2)
```

| term     | etasq | partial |
|:---------|------:|--------:|
| model    |  0.54 |    0.61 |
| features |  0.10 |    0.23 |

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-vanlissaWORCSWorkflowOpen2021" class="csl-entry">

Van Lissa, Caspar J., Andreas M. Brandmaier, Loek Brinkman, Anna-Lena
Lamprecht, Aaron Peikert, Marijn E. Struiksma, and Barbara M. I. Vreede.
2021. “WORCS: A Workflow for Open Reproducible Code in Science.” *Data
Science* 4 (1): 29–49. <https://doi.org/10.3233/DS-210031>.

</div>

</div>
