#!/usr/bin/env Rscript
# Run from array/combine/ after all array tasks have succeeded.
source("../../shared/bootstrap.R")

# Specify the exact array to combine; never guess the latest run.
job_id <- Sys.getenv("ARRAY_JOB_ID")
if (job_id == "") stop("Set ARRAY_JOB_ID to the array job ID before combining")
output_dir <- file.path("../output", job_id)
files <- list.files(output_dir, pattern = "^bootstrap_results_[0-9]+[.]csv$",
                    full.names = TRUE)

# Read partial files, stack their rows, and restore iteration order.
parts <- lapply(files, read.csv)
results <- do.call(rbind, parts)
results <- results[order(results$iteration), ]

# One essential check: do not report an interval from incomplete results.
stopifnot(identical(as.integer(results$iteration), seq_len(n_bootstrap)))

print(summarize_bootstrap(results$bootstrap_mean))
write.csv(results, file.path(output_dir, "bootstrap_means.csv"), row.names = FALSE)
cat("Combined results saved in", output_dir, "\n")
