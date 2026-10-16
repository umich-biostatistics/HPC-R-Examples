#!/usr/bin/env Rscript
# Run with the repository root as the working directory.
source("shared/bootstrap.R")

# One R process runs every iteration in order.
iterations <- seq_len(n_bootstrap)
time <- system.time({
  results <- sapply(iterations, bootstrap_one, data = data)
})

# Summarize the complete analysis.
print(summarize_bootstrap(results))
cat("Bootstrap computation seconds:", time[["elapsed"]], "\n")

# Define file names and output locations, creating where none exist
job_id <- Sys.getenv("SLURM_JOB_ID", "local-serial")
output_dir <- file.path("simple", "output", job_id)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# Turn results into a data frame and write CSV file
results_df <- data.frame(iteration = iterations, bootstrap_mean = results)
write.csv(results_df, file.path(output_dir, "bootstrap_means.csv"), row.names = FALSE)

cat("Results saved in", output_dir, "\n")
