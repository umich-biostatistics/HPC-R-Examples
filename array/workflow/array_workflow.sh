#!/bin/bash
# Run from HPC-R-Examples/: bash workflow/array_workflow.sh
set -e
mkdir -p logs

# --parsable returns the job ID so we can use it in the next submission.
array_id=$(sbatch --parsable array/bs_array.slurm)
echo "Array job: $array_id"

# afterok waits for every array task to finish successfully.
# ARRAY_JOB_ID tells the R combine script which results to read.
sbatch --dependency="afterok:$array_id" --export="ALL,ARRAY_JOB_ID=$array_id" \
  array/combine/combine_csv.slurm
