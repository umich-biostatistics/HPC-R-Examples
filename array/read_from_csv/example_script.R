# example_script.R
# Example R script to use with vars_from_csv.slrum

# Enhanced argument parsing with error handling
parse_args <- function(args) {
  # Initialize parameters with defaults
  params <- list(sigma = NULL, beta_mag = NULL)

  # Parse command line arguments
  for (arg in args) {
    if (grepl("^--sigma=", arg)) {
      params$sigma <- as.numeric(sub("^--sigma=", "", arg))
    } else if (grepl("^--beta_mag=", arg)) {
      params$beta_mag <- as.numeric(sub("^--beta_mag=", "", arg))
    } else if (arg %in% c("-h", "--help")) {
      cat("Usage: Rscript example_script.R --sigma=<value> --beta_mag=<value>\n")
      cat("  --sigma     : Sigma parameter (numeric)\n")
      cat("  --beta_mag  : Beta magnitude parameter (numeric)\n")
      cat("  --help, -h  : Show this help message\n")
      quit(status = 0)
    } else {
      warning(paste("Unknown argument:", arg))
    }
  }

  # Validate required parameters
  if (is.null(params$sigma) || is.null(params$beta_mag)) {
    stop("Both --sigma and --beta_mag parameters are required")
  }

  if (is.na(params$sigma) || is.na(params$beta_mag)) {
    stop("Invalid numeric values provided for parameters")
  }

  return(params)
}

# Main execution
main <- function() {
  args <- commandArgs(trailingOnly = TRUE)

  # Handle case with no arguments
  if (length(args) == 0) {
    cat("No arguments provided. Use --help for usage information.\n")
    quit(status = 1)
  }

  # Parse and validate arguments
  params <- tryCatch({
    parse_args(args)
  }, error = function(e) {
    cat("Error:", e$message, "\n")
    quit(status = 1)
  })

  # Print parameters
  cat("Parameters received:\n")
  cat("  sigma:", params$sigma, "\n")
  cat("  beta_mag:", params$beta_mag, "\n")

  # Perform calculations
  sum_val <- params$sigma + params$beta_mag
  product_val <- params$sigma * params$beta_mag

  cat("\nCalculations:\n")
  cat("  sum:", sum_val, "\n")
  cat("  product:", product_val, "\n")

  # Get SLURM array task ID for reproducible seeding and file naming
  task_id <- Sys.getenv("SLURM_ARRAY_TASK_ID", unset = "1")
  task_id_num <- as.numeric(task_id)

  # Example: Simple simulation or analysis
  set.seed(task_id_num)  # Use SLURM task ID for reproducible but unique results
  n_samples <- 1000
  samples <- rnorm(n_samples, mean = params$sigma, sd = params$beta_mag)

  cat("\nSimulation results (task", task_id, ", n =", n_samples, "):\n")
  cat("  mean:", round(mean(samples), 4), "\n")
  cat("  sd:", round(sd(samples), 4), "\n")
  cat("  range: [", round(min(samples), 4), ",", round(max(samples), 4), "]\n")

  # Save results to file using SLURM task ID
  output_file <- paste0("results_task_", task_id, ".csv")
  results_df <- data.frame(
    sigma = params$sigma,
    beta_mag = params$beta_mag,
    sum = sum_val,
    product = product_val,
    sim_mean = mean(samples),
    sim_sd = sd(samples),
    sim_min = min(samples),
    sim_max = max(samples)
  )

  write.csv(results_df, output_file, row.names = FALSE)
  cat("\nResults saved to:", output_file, "\n")
}

# Execute main function
if (!interactive()) {
  main()
}
