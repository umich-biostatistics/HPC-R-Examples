#!/usr/bin/env Rscript
# Run from array/ using bs_array.slurm.
source("../shared/bootstrap.R")

# Slurm runs a separate copy of this script for each task in --array=1-4.
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
task_count <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT"))
job_id <- Sys.getenv("SLURM_ARRAY_JOB_ID")

# Split ITERATIONS, not observations: every task uses the same full dataset.
# With four tasks, task 1 gets 1, 5, 9, ...; task 2 gets 2, 6, 10, ...
all_iterations <- seq_len(n_bootstrap)
iterations <- all_iterations[(all_iterations - 1) %% task_count + 1 == task_id]
time <- system.time({
  bootstrap_means <- unlist(lapply(iterations, bootstrap_one, data = data))
})

# These are partial results. Calculate the final interval in the combine step.
cat("Task", task_id, "completed", length(iterations), "iterations\n")
cat("This task's computation seconds:", time[["elapsed"]], "\n")
output_dir <- file.path("output", job_id)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
results <- data.frame(iteration = iterations, bootstrap_mean = as.numeric(bootstrap_means))
filename <- paste0("bootstrap_results_", task_id, ".csv")
write.csv(results, file.path(output_dir, filename), row.names = FALSE)
cat("Partial results saved in", file.path(output_dir, filename), "\n")
