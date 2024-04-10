i <- Sys.getenv("SLURM_ARRAY_TASK_ID")
print(paste0("Entering loop number:", i))
Sys.sleep(5)
