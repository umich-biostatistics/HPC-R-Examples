#!/bin/bash
# Submit the combine step only after the complete array succeeds.
set -euo pipefail
cd "$(dirname "$0")/.."
array_submission=$(cd array && sbatch --parsable bs_array.slurm)
# --parsable may append ;cluster to the numeric job ID.
array_id=${array_submission%%;*}
[[ "$array_id" =~ ^[0-9]+$ ]] || { echo "Invalid array job ID" >&2; exit 1; }
echo "Array job: $array_id"
combine_submission=$(cd array/combine && sbatch --parsable \
  --dependency="afterok:$array_id" --export="ALL,ARRAY_JOB_ID=$array_id" \
  combine_csv.slurm)
echo "Combine job: $combine_submission (depends on array $array_id)"
echo "Monitor: squeue -u $USER"
