i <- Sys.getenv("SLURM_ARRAY_TASK_ID")
output <- paste0("Entering loop number:", i)
Sys.sleep(5)
save(output, file=paste0(i, ".Rdata"))
