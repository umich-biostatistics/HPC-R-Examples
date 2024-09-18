library(data.table)

job_id = Sys.getenv("SLURM_JOB_ID")

file_list <- list.files(
  path = "../csv/", 
  pattern ="bootstrap_summary_*",
  full.names = TRUE)

combine_data <- rbindlist(lapply(file_list, fread))

fwrite(combine_data, paste0(
  "../csv/combined_output_",
  job_id,
  ".csv"))
