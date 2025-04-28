#!/bin/bash
#
# This script submits the bootstrap array job and then submits the combine job
# with a dependency to run only after the array job has completed successfully.

set -e pipefail

# Set the current directory to the script location
cd "$(dirname "$0")"
cd ..

# Submit the array job and capture the job ID
echo "Submitting bootstrap array job..."
ARRAY_JOB_ID=$(cd array \
                && sbatch \
                --parsable \
                bs_array.slurm)
echo "Array job submitted with ID: $ARRAY_JOB_ID"

# Submit the combine job with dependency on the array job
echo "Submitting combine job with dependency on array job..."
COMBINE_JOB_ID=$(cd array/combine \
                    && sbatch \
                    --parsable \
                    --dependency=afterok:"$ARRAY_JOB_ID" \
                    combine_csv.slurm)
echo "Combine job submitted with ID: $COMBINE_JOB_ID"

# View queued jobs
squeue -u "$USER"