#!/usr/bin/env Rscript
# Run with the repository root as the working directory.
source("shared/bootstrap.R")

# Slurm runs a separate copy of this script for each task in --array=1-4.
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
task_count <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT"))
job_id <- Sys.getenv("SLURM_ARRAY_JOB_ID")

# Split ITERATIONS, not observations: every task uses the same full dataset.
# With four tasks, task 1 gets 1, 5, 9, ...; task 2 gets 2, 6, 10, ...
# Start at this task's ID, then step forward by the number of tasks.
iterations <- seq(from = task_id, to = n_bootstrap, by = task_count)

time <- system.time({
  # Run this task's iterations, just like the serial example.
  results <- lapply(iterations, bootstrap_one, data = data)
  bootstrap_means <- unlist(results)
})

# These are partial results. Calculate the final interval in the combine step.
cat("Task", task_id, "completed", length(iterations), "iterations\n")
cat("This task's computation seconds:", time[["elapsed"]], "\n")
output_dir <- file.path("array", "output", job_id)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
results <- data.frame(iteration = iterations, bootstrap_mean = as.numeric(bootstrap_means))
filename <- paste0("bootstrap_results_", task_id, ".csv")
write.csv(results, file.path(output_dir, filename), row.names = FALSE)
cat("Partial results saved in", file.path(output_dir, filename), "\n")
