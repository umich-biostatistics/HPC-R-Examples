# Load required library
if (!all(sapply(c("dplyr", "readr", "parallelly"), require, character.only = TRUE))) {
  install.packages(c("dplyr", "readr", "parallelly"), 
                   repos = "https://repo.miserver.it.umich.edu/cran/", 
                   quietly = TRUE)
}

library(dplyr)
library(readr)

directory_path <- "../csv/"

# Function to combine CSV files
combine_csv_files <- function(directory_path) {
  # Get list of CSV files in the directory
  csv_files <- list.files(path = directory_path, pattern = "bootstrap_results_*.csv", full.names = TRUE)
  
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

combined_data <- combine_csv_files(directory_path)

# Optional: Write the combined data to a new CSV file
write_csv(combined_data, "../csv/combined_output.csv")

# Print the first few rows of the combined data
print(head(combined_data))