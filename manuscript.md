Untitled
================
05 September, 2024

This manuscript uses the Workflow for Open Reproducible Code in Science
(Van Lissa et al. 2021) to ensure reproducibility and transparency. All
code <!--and data--> are available at
<https://github.com/cjvanlissa/moral_standing.git>.

This is an example of a non-essential citation (Van Lissa et al. 2021).
If you change the rendering function to `worcs::cite_essential`, it will
be removed.

<!--The function below inserts a notification if the manuscript is knit using synthetic data. Make sure to insert it after load_data().-->

## Results

``` r
temp_env <- new.env()
tar_load_everything(envir = temp_env)
res <- grep("res_", ls(envir = temp_env), value = TRUE)
tab_res <- data.frame(Model = res)
res <- lapply(res, get, envir = temp_env)
tab_res$R2_test <- sapply(res, `[[`, "rsq")
tab_res$R2_train <- sapply(res, `[[`, "rsq_train")
knitr::kable(tab_res, digits = 2)
```

| Model      | R2_test | R2_train |
|:-----------|--------:|---------:|
| res_lasso  |    0.31 |     0.33 |
| res_nn     |    0.14 |     0.60 |
| res_ranger |    0.29 |     0.94 |
| res_sr     |    0.20 |     0.17 |
| res_tree   |    0.33 |     0.37 |

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-vanlissaWORCSWorkflowOpen2021" class="csl-entry">

Van Lissa, Caspar J., Andreas M. Brandmaier, Loek Brinkman, Anna-Lena
Lamprecht, Aaron Peikert, Marijn E. Struiksma, and Barbara M. I. Vreede.
2021. “WORCS: A Workflow for Open Reproducible Code in Science.” *Data
Science* 4 (1): 29–49. <https://doi.org/10.3233/DS-210031>.

</div>

</div>
