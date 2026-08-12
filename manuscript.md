Towards a Predictive Model of Moral Concern
================
12 August, 2026

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

|  mse | mse_se | rsq_test | rsq_train | model  | features    |
|-----:|-------:|---------:|----------:|:-------|:------------|
| 1.37 |   0.05 |     0.55 |      0.55 | lasso  | all         |
| 1.39 |   0.06 |     0.54 |      0.54 | lasso  | target      |
| 2.73 |   0.09 |     0.02 |      0.02 | lasso  | judge       |
| 2.80 |   0.09 |     0.00 |      0.00 | lasso  | demographic |
| 1.26 |   0.18 |     0.58 |      0.58 | ranger | all         |
| 1.27 |   0.17 |     0.59 |      0.59 | ranger | target      |
| 2.70 |   0.27 |     0.03 |      0.03 | ranger | judge       |
| 2.83 |   0.27 |     0.00 |      0.00 | ranger | demographic |
| 1.66 |   0.18 |     0.44 |      0.44 | tree   | all         |
| 1.66 |   0.18 |     0.44 |      0.44 | tree   | target      |
| 2.71 |   0.27 |     0.02 |      0.02 | tree   | judge       |
| 2.80 |   0.30 |     0.00 |      0.00 | tree   | demographic |
| 1.60 |   0.33 |     0.49 |      0.49 | nn     | all         |
| 1.33 |   0.19 |     0.59 |      0.59 | nn     | target      |
| 2.88 |   0.30 |    -0.01 |     -0.01 | nn     | judge       |
| 2.87 |   0.33 |     0.02 |      0.02 | nn     | demographic |

The best performing model (or interpretable model whose cross-validated
mean squared error was within 1SE of the best model’s cross-validated
mean squared error) is lasso.all.cvm.

### Effect of Features and Model

The variance in model performance can be broken down into components due
to model and feature set:

``` r
tab_aov <- temp_env$analysis_results$etasqs
knitr::kable(tab_aov, digits = 2)
```

| term     | etasq | partial |
|:---------|------:|--------:|
| model    |  0.01 |    0.45 |
| features |  0.98 |    0.99 |

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-vanlissaWORCSWorkflowOpen2021" class="csl-entry">

Van Lissa, Caspar J., Andreas M. Brandmaier, Loek Brinkman, Anna-Lena
Lamprecht, Aaron Peikert, Marijn E. Struiksma, and Barbara M. I. Vreede.
2021. “WORCS: A Workflow for Open Reproducible Code in Science.” *Data
Science* 4 (1): 29–49. <https://doi.org/10.3233/DS-210031>.

</div>

</div>
