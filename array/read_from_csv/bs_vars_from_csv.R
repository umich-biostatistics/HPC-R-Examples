#!/usr/bin/env Rscript
# Run with the repository root as the working directory.

# Optional extension: each task receives a different mean and standard deviation.
# The task ID is the row number to use. It is 1 when you run this on your own
# computer, outside of Slurm.
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "1"))

# Read the parameter table and take this task's row: mean, standard deviation.
params <- read.csv("array/read_from_csv/params.csv")
mean_value <- params$mean[task_id]
sd_value <- params$sd[task_id]

# Generate a small simulated dataset using this task's parameters.
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
