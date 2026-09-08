# The same analysis is used in all three examples.
# Edit these two settings to change the size of the exercise.
n_observations <- 5000
n_bootstrap <- 1000

# Every script creates the same full dataset.
set.seed(123)
data <- rnorm(n_observations, mean = 5, sd = 2)

bootstrap_one <- function(iteration, data) {
  # An iteration always gets the same seed, regardless of where it runs.
  set.seed(1000 + iteration)
  # Sample the full dataset WITH replacement, then calculate its mean.
  mean(sample(data, size = length(data), replace = TRUE))
}

# Run this only after collecting ALL bootstrap means.
summarize_bootstrap <- function(bootstrap_means) {
  # The middle 95% of bootstrap means gives the percentile interval.
  c(original_mean = mean(data),
    bootstrap_mean = mean(bootstrap_means),
    quantile(bootstrap_means, c(0.025, 0.975)))
}
