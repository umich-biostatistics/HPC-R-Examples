#!/usr/bin/env Rscript

# Multicore bootstrap analysis script using parallelly for cluster creation
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

# SLURM job ID is read in from the environment for later use
job_id <- as.integer(Sys.getenv("SLURM_JOB_ID"))

# Set global seed for reproducibility of data generation
# Note: Per-chunk seeds are set later inside the bootstrap_chunk function
set.seed(job_id)

# Create output directories
output_dir <- file.path(getwd(), "output", job_id, "csv")
summary_dir <- file.path(getwd(), "summary", job_id)

dir.create(summary_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Generate sample data (in real scenarios, you'd load your data here)
data <- rnorm(50000, mean = 5, sd = 2)

# Function to perform bootstrap on a chunk of data
bootstrap_chunk <- function(chunk_id, n_bootstrap_per_chunk, data) {
  set.seed(job_id + chunk_id)
  replicate(n_bootstrap_per_chunk, mean(sample(data, replace = TRUE)))
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
  cl, c("bootstrap_chunk", "data", "n_bootstrap_per_chunk", "job_id")
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
writeLines(results, file.path(summary_dir, "multicore_bootstrap_results.txt"))

# Save detailed bootstrap means to CSV
write.csv(data.frame(bootstrap_mean = bootstrap_means),
          file = file.path(output_dir, "multicore_bootstrap_means.csv"),
          row.names = FALSE)

cat("Results have been saved to", file.path(summary_dir, "multicore_bootstrap_results.txt"), "\n")
cat("Detailed bootstrap means have been saved to", file.path(output_dir, "multicore_bootstrap_means.csv"), "\n")
