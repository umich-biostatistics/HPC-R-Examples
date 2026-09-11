#!/usr/bin/env Rscript
# Run with the repository root as the working directory.
source("shared/bootstrap.R")

# parallelly detects the CPUs available to this job, including Slurm limits.
n_workers <- parallelly::availableCores()
iterations <- seq_len(n_bootstrap)

# Workers are separate R processes on the same node.
# autoStop cleans up workers when the cluster object is garbage-collected.
run_multicore <- function() {
  cl <- parallelly::makeClusterPSOCK(n_workers, autoStop = TRUE)

  # Ask the workers to run bootstrap_one() for each iteration.
  # Each call uses the full dataset and returns one mean.
  results <- parallel::parLapply(cl, iterations, bootstrap_one, data = data)

  # parLapply() returns a list of means, in iteration order.
  # Turn that list into a numeric vector for the summary and CSV.
  bootstrap_means <- unlist(results)
  return(bootstrap_means)
}
time <- system.time({
  bootstrap_means <- run_multicore()
})

# The coordinating R process now has all the results.
print(summarize_bootstrap(bootstrap_means))
cat("Workers:", n_workers, "\n")
cat("Seconds including worker startup and collection:", time[["elapsed"]], "\n")

job_id <- Sys.getenv("SLURM_JOB_ID", "local-multicore")
output_dir <- file.path("multicore", "output", job_id)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
results <- data.frame(iteration = iterations, bootstrap_mean = bootstrap_means)
write.csv(results, file.path(output_dir, "bootstrap_means.csv"), row.names = FALSE)
cat("Results saved in", output_dir, "\n")
