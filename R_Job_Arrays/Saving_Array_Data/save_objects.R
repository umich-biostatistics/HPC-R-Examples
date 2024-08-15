i <- Sys.getenv("SLURM_ARRAY_TASK_ID")

mtcars$mpg10 <- mtcars$mpg / 10

resampled_mtcars = mtcars[sample(nrow(mtcars),
                                 replace = TRUE), ]

fit = rstanarm::stan_glm(mpg10 ~ wt + cyl + am,
                         data = resampled_mtcars,
                         chains = 1,
                         iter = 50000)

save(fit, file = paste0(i, ".Rdata"))
