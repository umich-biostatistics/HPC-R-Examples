# Simple bootstrap analysis script with file output

# Set seed for reproducibility
set.seed(123)

# Generate sample data
data <- rnorm(50000, mean = 5, sd = 2)

# Function to calculate mean
calc_mean <- function(x) {
  mean(x)
}

# Perform bootstrap
n_bootstrap <- 50000
speed <- system.time({
  bootstrap_means <- replicate(n_bootstrap, calc_mean(sample(data, replace = TRUE)))
  
  # Calculate confidence interval
  ci <- quantile(bootstrap_means, c(0.025, 0.975))
})

# Create results string
results <- paste0(
  "Original data mean: ", mean(data), "\n",
  "Bootstrap mean: ", mean(bootstrap_means), "\n",
  "95% Confidence Interval: ", ci[1], " - ", ci[2], "\n",
  "Runtime: ", speed["elapsed"], "\n"
)

# Print results to console and file
dir.create("summary")
writeLines(results, "summary/simple_bootstrap_results.txt")

cat("Results have been saved to simple_bootstrap_results.txt\n")
