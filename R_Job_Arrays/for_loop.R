# Convert mpg variable to base 10 for simplicity
mtcars$mpg10 <- mtcars$mpg / 10

# 50 iterations, resampling and fitting to lm
for (i in 1:50){
  resampled_mtcars = mtcars[
    sample(nrow(mtcars),
    replace = TRUE), ]

  fit = rstanarm::stan_glm(
    mpg10 ~ wt + cyl + am,
    data = resampled_mtcars,
    chains = 1,
    iter = 50000)
}
