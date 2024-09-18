#!/usr/bin/env Rscript

# Bootstrap analysis script for SLURM job array with file output

# Get the task ID from SLURM_ARRAY_TASK_ID
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
task_count <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT"))

# Set seed based on task ID for reproducibility
set.seed(123 + task_id)

# Create output directories
dir.create("summary", showWarnings = FALSE)
dir.create("csv", showWarnings = FALSE)

# Generate sample data (in real scenarios, you'd load your data here)
data <- rnorm(50000, mean = 5, sd = 2)

# Function to calculate mean
calc_mean <- function(x) {
  mean(x)
}

# Perform bootstrap for this task
n_bootstrap_per_task <- 50000 / task_count
speed <- system.time({
  bootstrap_means <- replicate(n_bootstrap_per_task, calc_mean(sample(data, replace = TRUE)))
})

# Save detailed results for this task
results <- data.frame(task_id = task_id, iteration = 1:n_bootstrap_per_task, mean = bootstrap_means)
write.csv(results, file = paste0("csv/bootstrap_results_", task_id, ".csv"), row.names = FALSE)

# Calculate summary statistics for this task
task_mean <- mean(bootstrap_means)
task_ci <- quantile(bootstrap_means, c(0.025, 0.975))

# Create summary string
summary <- paste0(
  "Task ID: ", task_id, " of ", task_count, "\n",
  "Number of bootstrap iterations: ", n_bootstrap_per_task, "\n",
  "Mean of bootstrap means: ", task_mean, "\n",
  "95% CI of bootstrap means: ", task_ci[1], " - ", task_ci[2], "\n",
  "Runtime: ", speed["elapsed"], "\n"
)

# Save summary to a text file
writeLines(summary, paste0("summary/bootstrap_summary_", task_id, ".txt"))

cat("Task", task_id, "completed. Results and summary saved to files.\n")

