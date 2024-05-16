# Create an empty list with a length of 10 for storing the data
results <- vector(mode = "list", 10L)

# Loop through each file saved with save_objects.R
# Place the data into the coresponding element in the list
for (i in 1:10){
  load(paste0("Rdata/", i, ".Rdata"))
  results[[i]] <- output
}

# Save the combined list as combined_results.Rdata
save(results, file=paste0("Rdata/combined/combined_results.Rdata"))
