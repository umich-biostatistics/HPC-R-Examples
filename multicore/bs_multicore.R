#!/usr/bin/env Rscript
# Run from multicore/. Use exactly the same analysis as serial.
source("../shared/bootstrap.R")

# Slurm gives this job four CPUs. Outside Slurm, default to one worker.
n_workers <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))
iterations <- seq_len(n_bootstrap)

# Workers are separate R processes on the same node.
# A function lets on.exit() stop them even if a calculation fails.
run_multicore <- function() {
  cl <- parallel::makePSOCKcluster(n_workers)
  on.exit(parallel::stopCluster(cl))

  # Like lapply(), but distribute iterations to the workers.
  # R sends each worker the function and the full dataset.
  unlist(parallel::parLapply(cl, iterations, bootstrap_one, data = data))
}
time <- system.time({
  bootstrap_means <- run_multicore()
})

# The coordinating R process now has all the results.
print(summarize_bootstrap(bootstrap_means))
cat("Workers:", n_workers, "\n")
cat("Seconds including worker startup and collection:", time[["elapsed"]], "\n")

job_id <- Sys.getenv("SLURM_JOB_ID", "local-multicore")
output_dir <- file.path("output", job_id)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
results <- data.frame(iteration = iterations, bootstrap_mean = bootstrap_means)
write.csv(results, file.path(output_dir, "bootstrap_means.csv"), row.names = FALSE)
cat("Results saved in", output_dir, "\n")
