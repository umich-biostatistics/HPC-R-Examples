#!/usr/bin/env Rscript
# Run from simple/. Load the data, settings, and bootstrap function.
source("../shared/bootstrap.R")

# One R process runs every iteration in order.
iterations <- seq_len(n_bootstrap)
time <- system.time({
  bootstrap_means <- unlist(lapply(iterations, bootstrap_one, data = data))
})

# Summarize the complete analysis.
print(summarize_bootstrap(bootstrap_means))
cat("Bootstrap computation seconds:", time[["elapsed"]], "\n")

# Job IDs name output folders; they do not affect the random samples.
job_id <- Sys.getenv("SLURM_JOB_ID", "local-serial")
output_dir <- file.path("output", job_id)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
results <- data.frame(iteration = iterations, bootstrap_mean = bootstrap_means)
write.csv(results, file.path(output_dir, "bootstrap_means.csv"), row.names = FALSE)
cat("Results saved in", output_dir, "\n")
