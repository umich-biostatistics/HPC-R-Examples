#!/usr/bin/env Rscript
# Run with the repository root as the working directory.

# Optional extension: each task receives a different mean and standard deviation.
# The batch script passes two positional arguments, for example: 5 2
args <- commandArgs(trailingOnly = TRUE)
mean_value <- as.numeric(args[1])
sd_value <- as.numeric(args[2])

# Generate a small simulated dataset using this task's parameters.
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "1"))
set.seed(task_id)
samples <- rnorm(1000, mean = mean_value, sd = sd_value)
results <- data.frame(task_id = task_id, mean = mean_value, sd = sd_value,
                      sample_mean = mean(samples), sample_sd = sd(samples))
print(results)

job_id <- Sys.getenv("SLURM_ARRAY_JOB_ID", "local-parameters")
output_dir <- file.path("array/read_from_csv", "output", job_id)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(results, file.path(output_dir, paste0("results_task_", task_id, ".csv")),
          row.names = FALSE)
