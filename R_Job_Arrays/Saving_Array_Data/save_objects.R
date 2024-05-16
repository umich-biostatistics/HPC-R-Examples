# Get SLURM task ID variable from shell
i <- Sys.getenv("SLURM_ARRAY_TASK_ID")

# Output loop number based on SLURM task ID into R console
output <- paste0("Entering loop number:", i)

# Wait for 5 minutes before saving - so we can see it in the squeue
Sys.sleep(5)

save(output, file <- paste0("Rdata/", i, ".Rdata"))
