#!/usr/bin/env Rscript

# Parallel bootstrap analysis script using parallelly for cluster creation
# and parallel for computation

# Check for and install parallelly package
if (!require(parallelly)) {
  install.packages(
    "parallelly",
    repos = "https://repo.miserver.it.umich.edu/cran/",
    quietly = TRUE
  )
}

library(parallelly)
library(parallel)

# Set seed for reproducibility
set.seed(123)

# Create output directories
output_dir <- file.path(getwd(), "output", job_id)
summary_dir <- file.path(getwd(), "summary", job_id)

dir.create(summary_dir, showWarnings = FALSE)
dir.create(output_dir, showWarnings = FALSE)

# Generate sample data (in real scenarios, you'd load your data here)
data <- rnorm(50000, mean = 5, sd = 2)

# Function to calculate mean
calc_mean <- function(x) {
  mean(x)
}

# Function to perform bootstrap on a chunk of data
bootstrap_chunk <- function(chunk_id, n_bootstrap_per_chunk, data) {
  set.seed(123 + chunk_id)  # Ensure reproducibility for each chunk
  replicate(n_bootstrap_per_chunk, calc_mean(sample(data, replace = TRUE)))
}

# Set up parallel processing
n_cores <- parallelly::availableCores()
n_bootstrap <- 50000
n_chunks <- n_cores
n_bootstrap_per_chunk <- n_bootstrap / n_chunks

# Create cluster with necessary functions and data
cl <- parallelly::makeClusterPSOCK(n_cores, autoStop = TRUE)

# Export necessary functions and data to the cluster
clusterExport(
  cl, c("calc_mean", "bootstrap_chunk", "data", "n_bootstrap_per_chunk")
)

# Perform parallel bootstrap
speed <- system.time({
  bootstrap_means <- unlist(
    parLapply(
      cl,
      1:n_chunks,
      function(id) bootstrap_chunk(id, n_bootstrap_per_chunk, data)
    )
  )
  # Calculate confidence interval
  ci <- quantile(bootstrap_means, c(0.025, 0.975))
})

# Create results string
results <- paste0(
  "Original data mean: ", mean(data), "\n",
  "Bootstrap mean: ", mean(bootstrap_means), "\n",
  "95% Confidence Interval: ", ci[1], " - ", ci[2], "\n",
  "Number of cores used: ", n_cores, "\n",
  "Total bootstrap iterations: ", n_bootstrap, "\n",
  "Runtime: ", speed["elapsed"], "\n"
)

# Print results to console and file
cat(results)
writeLines(results, file.path(summary_dir, "parallel_bootstrap_results.txt"))

# Save detailed bootstrap means to CSV
write.csv(data.frame(bootstrap_mean = bootstrap_means),
          file = file.path("csv", "parallel_bootstrap_means.csv"),
          row.names = FALSE)

cat("Results have been saved to", file.path(summary_dir, "parallel_bootstrap_results.txt"), "\n")
cat("Detailed bootstrap means have been saved to", file.path("csv", "parallel_bootstrap_means.csv"), "\n")
