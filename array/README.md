# Bootstrap array

Follow the [main lesson](../README.md) for submission and combination. This example
submits from the repository root and uses a contiguous array starting at 1, normally `--array=1-4`.
Each task gets some iteration IDs but uses the same full dataset.

Partial files are `array/output/ARRAY_ID/bootstrap_results_TASK_ID.csv`. The combine
script sorts all rows by iteration and checks that every iteration appears once.
It writes `array/output/ARRAY_ID/bootstrap_means.csv` and prints the final summary.
Keep the shared settings unchanged until combination finishes.

## Seeding across tasks

`bs_array.R` splits **iteration IDs** round-robin across tasks (task 1 gets
1, 5, 9, …; task 2 gets 2, 6, 10, … with four tasks), not a fixed block per task.
Which task ends up running a given iteration therefore depends on `--array`'s
task count: change it from 4 to 8, for example, and task 2 now handles a
different set of iterations than before.

That would make results depend on the array size if tasks seeded by their own
task ID. Instead, `bootstrap_one()` seeds using the iteration number itself
(`set.seed(1000 + iteration)`), so a given iteration always draws the same
resample regardless of which task happens to run it, or how many tasks the
array has. This is what lets `array/output/.../bootstrap_means.csv` match the
serial and multicore results, and lets you resize `--array` without changing
the answer.

## Optional local simulation

On your own computer with R installed, start in the repository root:

```bash
for task in 1 2 3 4; do
  SLURM_ARRAY_JOB_ID=local-array SLURM_ARRAY_TASK_ID="$task" \
  SLURM_ARRAY_TASK_COUNT=4 Rscript --vanilla array/bs_array.R
done
ARRAY_JOB_ID=local-array Rscript --vanilla array/combine/combine_csv.R
```

This runs tasks sequentially to demonstrate partitioning without Slurm. It does
not simulate cluster scheduling. Reruns overwrite files; use a new array ID if
you change the number of tasks, to avoid mixing old and new outputs.

Next: [dependency workflow](../workflow/README.md) or [parameter sweep](read_from_csv/README.md).
