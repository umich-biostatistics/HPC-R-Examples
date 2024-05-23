#!/bin/bash

# Combine the steps of running the save_array and combine jobs into one script

# Submit the save_array job, grab the last field in the output (the job ID)
# and assign that as a variable, "array"
array=$(sbatch save_array.slurm | awk '{print $NF}')

# Submit a second job to combine the data with a dependency of "afterok"
# meaning only run the combine job once the previous job has completed successfully
sbatch --dependency=afterok:"$array" combine.slurm
