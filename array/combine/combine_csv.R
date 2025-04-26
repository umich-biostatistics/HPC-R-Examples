# List of required packages
required_packages <- c("dplyr", "readr")

# Check if required packages are installed
missing_packages <- required_packages[
  !sapply(required_packages, require, character.only = TRUE)
]

if (length(missing_packages) > 0) {
  install.packages(
    missing_packages,
    repos = "https://repo.miserver.it.umich.edu/cran/",
    quietly = TRUE
  )
}

library(dplyr)
library(readr)

# Import previously run job array ID
array_id <- as.integer(Sys.getenv("ARRAY_JOB_ID"))

# Import job ID of combine job
job_id <- as.integer(Sys.getenv("SLURM_JOB_ID"))

# Find the last modified directory in ../output
output_path <- "../output"

if (dir.exists(output_path)) {
  # Get all directories in ../output
  all_dirs <- list.dirs(output_path, recursive = FALSE)

  if (length(all_dirs) > 0) {
    # Get file info and find most recently modified directory
    dir_info <- file.info(all_dirs)
    dir_info$path <- rownames(dir_info)
    array_data <- dir_info[order(dir_info$mtime, decreasing = TRUE), "path"][1]
  } else {
    stop("No directories found in ../output")
  }
} else {
  stop("Directory ../output does not exist")
}

# Fallback to array_id if specified
if (!is.na(array_id) && array_id > 0) {
  array_data_from_id <- file.path("../output", array_id)
  if (dir.exists(array_data_from_id)) {
    array_data <- array_data_from_id
  }
}

# Function to combine CSV files
combine_csv_files <- function(array_data) {
  # Get list of CSV files in the directory
  csv_files <- list.files(
    path = array_data,
    pattern = "^bootstrap_results_.*\\.csv$",
    full.names = TRUE
  )

  # Check if any CSV files were found
  if (length(csv_files) == 0) {
    stop("No CSV files found in the specified directory.")
  }

  # Read and combine all CSV files
  combined_data <- csv_files %>%
    lapply(read_csv) %>%
    bind_rows()

  return(combined_data)
}

combined_data <- combine_csv_files(array_data)

# Optional: Write the combined data to a new CSV file
combined_output <- file.path(
  array_data,
  "combined",
  "combined_data.csv"
)

# Create directory if it doesn't exist
dir.create(
  dirname(combined_output),
  showWarnings = FALSE,
  recursive = TRUE
)

# Write with error handling
tryCatch({
  write.csv(combined_data, combined_output, row.names = FALSE)
  cat("Successfully wrote combined data to:", combined_output, "\n")
}, error = function(e) {
  stop("Failed to write combined data: ", e$message)
})
