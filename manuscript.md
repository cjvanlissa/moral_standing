Towards a Predictive Model of Moral Concern
================
09 September, 2026

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
| 1.37 |   0.05 |     0.55 |      0.55 | lasso  | primary     |
| 1.39 |   0.06 |     0.54 |      0.54 | lasso  | target      |
| 2.73 |   0.09 |     0.02 |      0.02 | lasso  | judge       |
| 2.80 |   0.09 |     0.00 |      0.00 | lasso  | demographic |
| 1.26 |   0.18 |     0.58 |      0.58 | ranger | all         |
| 1.25 |   0.18 |     0.58 |      0.58 | ranger | primary     |
| 1.28 |   0.17 |     0.59 |      0.59 | ranger | target      |
| 2.69 |   0.27 |     0.05 |      0.05 | ranger | judge       |
| 2.83 |   0.26 |     0.00 |      0.00 | ranger | demographic |
| 1.66 |   0.18 |     0.44 |      0.44 | tree   | all         |
| 1.66 |   0.18 |     0.44 |      0.44 | tree   | primary     |
| 1.66 |   0.18 |     0.44 |      0.44 | tree   | target      |
| 2.71 |   0.27 |     0.02 |      0.02 | tree   | judge       |
| 2.80 |   0.30 |     0.00 |      0.00 | tree   | demographic |
| 1.68 |   0.38 |     0.48 |      0.48 | nn     | all         |
| 1.47 |   0.25 |     0.51 |      0.51 | nn     | primary     |
| 1.31 |   0.17 |     0.57 |      0.57 | nn     | target      |
| 2.84 |   0.29 |    -0.05 |     -0.05 | nn     | judge       |
| 2.84 |   0.26 |    -0.08 |     -0.08 | nn     | demographic |

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
| model    |  0.02 |    0.57 |
| features |  0.97 |    0.99 |

## Interpretation

``` r
X <- model.matrix(moral_concern ~., temp_env$dat_features$all$train)[, -1]
Y <- as.numeric(temp_env$dat_features$all$train$moral_concern)
# 
sdx <- apply(X, 2, sd)
coefs <- as.numeric(glmnet:::coef.glmnet(temp_env$res_lasso$all$res, s = "lambda.1se"))
coefs_sxy <- coefs
coefs_sxy[-1] <- coefs[-1] * (sdx/sd(Y))

tab_coef <- data.frame(Predictor = c("Intercept", rownames(temp_env$res_lasso$all$res$beta)), b = coefs
                       , beta = coefs_sxy
                       )

tab_coef <- tab_coef[order(abs(tab_coef$beta), decreasing = T), , drop = F]
knitr::kable(tab_coef, caption = "LASSO regression coefficients.")
```

|     | Predictor          |          b |       beta |
|:----|:-------------------|-----------:|-----------:|
| 1   | Intercept          |  5.3810119 |  5.3810119 |
| 2   | sentience          |  0.4612834 |  0.2761184 |
| 9   | vulnerable         |  0.4361314 |  0.2610628 |
| 6   | beautiful          |  0.2835395 |  0.1697232 |
| 8   | utility            |  0.1749957 |  0.1047502 |
| 5   | harmful            | -0.1356242 | -0.0811830 |
| 7   | similar            |  0.1244913 |  0.0745189 |
| 4   | socog              |  0.0616813 |  0.0369216 |
| 10  | sdo                | -0.0273549 | -0.0163743 |
| 22  | empathy_ec         |  0.0257729 |  0.0154273 |
| 3   | agency             |  0.0000000 |  0.0000000 |
| 11  | rwa                |  0.0000000 |  0.0000000 |
| 12  | hexaco_hh          |  0.0000000 |  0.0000000 |
| 13  | hexaco_emo         |  0.0000000 |  0.0000000 |
| 14  | hexaco_ex          |  0.0000000 |  0.0000000 |
| 15  | hexaco_ag          |  0.0000000 |  0.0000000 |
| 16  | hexaco_con         |  0.0000000 |  0.0000000 |
| 17  | hexaco_op          |  0.0000000 |  0.0000000 |
| 18  | trust              |  0.0000000 |  0.0000000 |
| 19  | aot                |  0.0000000 |  0.0000000 |
| 20  | moraldisgust       |  0.0000000 |  0.0000000 |
| 21  | empathy_pt         |  0.0000000 |  0.0000000 |
| 23  | empathy_pd         |  0.0000000 |  0.0000000 |
| 24  | moralfound_care    |  0.0000000 |  0.0000000 |
| 25  | moralfound_fair    |  0.0000000 |  0.0000000 |
| 26  | moralfound_lib     |  0.0000000 |  0.0000000 |
| 27  | moralfound_aut     |  0.0000000 |  0.0000000 |
| 28  | moralfound_ing     |  0.0000000 |  0.0000000 |
| 29  | moralfound_pur     |  0.0000000 |  0.0000000 |
| 30  | identity_allbeings |  0.0000000 |  0.0000000 |
| 31  | util_ib            |  0.0000000 |  0.0000000 |
| 32  | util_ih            |  0.0000000 |  0.0000000 |
| 33  | gendermale         |  0.0000000 |  0.0000000 |
| 34  | age                |  0.0000000 |  0.0000000 |
| 35  | pet_childhood      |  0.0000000 |  0.0000000 |
| 36  | conservative       |  0.0000000 |  0.0000000 |
| 37  | religious          |  0.0000000 |  0.0000000 |
| 38  | education          |  0.0000000 |  0.0000000 |
| 39  | income             |  0.0000000 |  0.0000000 |

LASSO regression coefficients.

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-vanlissaWORCSWorkflowOpen2021" class="csl-entry">

Van Lissa, Caspar J., Andreas M. Brandmaier, Loek Brinkman, Anna-Lena
Lamprecht, Aaron Peikert, Marijn E. Struiksma, and Barbara M. I. Vreede.
2021. “WORCS: A Workflow for Open Reproducible Code in Science.” *Data
Science* 4 (1): 29–49. <https://doi.org/10.3233/DS-210031>.

</div>

</div>
