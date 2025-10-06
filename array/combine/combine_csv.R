# Load required packages (install if missing)
if (!require(dplyr, quietly = TRUE)) {
  install.packages("dplyr", repos = "https://repo.miserver.it.umich.edu/cran/")
  library(dplyr)
}
if (!require(readr, quietly = TRUE)) {
  install.packages("readr", repos = "https://repo.miserver.it.umich.edu/cran/")
  library(readr)
}

# Get environment variables
array_id <- Sys.getenv("ARRAY_JOB_ID")

# Find output directory (use array_id if provided, otherwise most recent)
output_path <- "../output"
if (!dir.exists(output_path)) {
  stop("Directory ../output does not exist")
}

if (array_id != "" && dir.exists(file.path(output_path, array_id))) {
  array_data <- file.path(output_path, array_id)
} else {
  # Use most recently modified directory
  dirs <- list.dirs(output_path, recursive = FALSE)
  if (length(dirs) == 0) stop("No directories found in ../output")
  array_data <- dirs[order(file.info(dirs)$mtime, decreasing = TRUE)][1]
}

# Find and combine CSV files
csv_files <- list.files(
  path = array_data,
  pattern = "^bootstrap_results_.*\\.csv$",
  full.names = TRUE
)

if (length(csv_files) == 0) {
  stop("No CSV files found in directory: ", array_data)
}

# Combine all CSV files
combined_data <- csv_files %>%
  lapply(read_csv, show_col_types = FALSE) %>%
  bind_rows()

# Write combined data to output file
combined_output <- file.path(array_data, "combined", "combined_data.csv")
dir.create(dirname(combined_output), showWarnings = FALSE, recursive = TRUE)

write.csv(combined_data, combined_output, row.names = FALSE)
cat("Successfully wrote combined data to:", combined_output, "\n")
