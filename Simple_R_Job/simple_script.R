# Rescale mpg variable by factor of 10
mtcars$mpg10 <- mtcars$mpg / 10

# Fit linear model to predict mpg
fit = rstanarm::stan_glm(
            mpg10 ~ wt + cyl + am,
            data = mtcars, 
            chains = 1, iter = 50000)

# Save output to Rdata file
save(fit, file = "mod.rda")
