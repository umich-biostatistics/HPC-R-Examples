# Bootstrap array

Follow the [main lesson](../README.md) for submission and combination. This example
uses a contiguous array starting at 1, normally `--array=1-4`.
Each task gets some iteration IDs but uses the same full dataset.

Partial files are `output/ARRAY_ID/bootstrap_results_TASK_ID.csv`. The combine
script sorts all rows by iteration and checks that every iteration appears once.
It writes `output/ARRAY_ID/bootstrap_means.csv` and prints the final summary.
Keep the shared settings unchanged until combination finishes.

## Optional local simulation

On your own computer with R installed, start in this directory:

```bash
for task in 1 2 3 4; do
  SLURM_ARRAY_JOB_ID=local-array SLURM_ARRAY_TASK_ID="$task" \
  SLURM_ARRAY_TASK_COUNT=4 Rscript --vanilla bs_array.R
done
(cd combine && ARRAY_JOB_ID=local-array Rscript --vanilla combine_csv.R)
```

This runs tasks sequentially to demonstrate partitioning without Slurm. It does
not simulate cluster scheduling. Reruns overwrite files; use a new array ID if
you change the number of tasks, to avoid mixing old and new outputs.

Next: [dependency workflow](../workflow/README.md) or [parameter sweep](read_from_csv/README.md).
