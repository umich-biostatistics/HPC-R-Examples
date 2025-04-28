# Simple bootstrap analysis script with file output

# Set seed for reproducibility
set.seed(123)

# Create output directories
job_id <- as.integer(Sys.getenv("SLURM_ARRAY_JOB_ID"))
output_dir <- file.path(getwd(), "output", job_id)
summary_dir <- file.path(getwd(), "summary", job_id)

dir.create(summary_dir, showWarnings = FALSE)
dir.create(output_dir, showWarnings = FALSE)

# Generate sample data
data <- rnorm(50000, mean = 5, sd = 2)

# Function to calculate mean
calc_mean <- function(x) {
  mean(x)
}

# Perform bootstrap
n_bootstrap <- 50000

speed <- system.time({
  bootstrap_means <- replicate(
    n_bootstrap, calc_mean(sample(data, replace = TRUE))
  )
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

# Save results to file
writeLines(results, file.path(summary_dir, "simple_bootstrap_results.txt"))

write.csv(data.frame(bootstrap_mean = bootstrap_means),
          file = file.path(output_dir, "simple_bootstrap_means.csv"),
          row.names = FALSE)

cat("Results have been saved to simple_bootstrap_results.txt\n")
