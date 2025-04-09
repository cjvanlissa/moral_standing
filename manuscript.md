Untitled
================
09 April, 2025

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

| rsq_test | rsq_train | model  | features    |
|---------:|----------:|:-------|:------------|
|     0.00 |      0.00 | lasso  | all         |
|     0.00 |      0.00 | lasso  | target      |
|     0.00 |      0.00 | lasso  | judge       |
|     0.00 |      0.00 | lasso  | demographic |
|     0.00 |      0.00 | ranger | all         |
|     0.00 |      0.00 | ranger | target      |
|     0.00 |      0.00 | ranger | judge       |
|     0.00 |      0.00 | ranger | demographic |
|     0.00 |      0.00 | tree   | all         |
|     0.00 |      0.00 | tree   | target      |
|     0.00 |      0.00 | tree   | judge       |
|     0.00 |      0.00 | tree   | demographic |
|    -0.18 |     -0.18 | nn     | all         |
|    -0.01 |     -0.01 | nn     | target      |
|     0.01 |      0.01 | nn     | judge       |
|    -0.07 |     -0.07 | nn     | demographic |

The best performing model (or interpretable model within 5% of the best
overall model) is nn.judge.

### Effect of Features and Model

The variance in model performance can be broken down into components due
to model and feature set:

``` r
tab_aov <- temp_env$analysis_results$etasqs
knitr::kable(tab_aov, digits = 2)
```

| term     | etasq | partial |
|:---------|------:|--------:|
| model    |  0.38 |    0.45 |
| features |  0.16 |    0.25 |

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-vanlissaWORCSWorkflowOpen2021" class="csl-entry">

Van Lissa, Caspar J., Andreas M. Brandmaier, Loek Brinkman, Anna-Lena
Lamprecht, Aaron Peikert, Marijn E. Struiksma, and Barbara M. I. Vreede.
2021. “WORCS: A Workflow for Open Reproducible Code in Science.” *Data
Science* 4 (1): 29–49. <https://doi.org/10.3233/DS-210031>.

</div>

</div>
