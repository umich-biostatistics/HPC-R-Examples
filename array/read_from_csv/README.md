# Optional: different inputs per array task

Unlike the main bootstrap array, this example intentionally gives tasks different
inputs. `params.csv` has a header row, `mean,sd`, and then one row per task giving
a normal-distribution mean and a positive standard deviation:

```
mean,sd
5,2
5,4
10,2
```

The R script reads `params.csv` itself with `read.csv` and takes the row number
that matches `SLURM_ARRAY_TASK_ID`, so the batch script only needs to call
`Rscript`. R then generates 1,000 samples and reports their sample mean and
standard deviation. Keep `--array=1-3` matched to the number of data rows, not
counting the header.

From the repository root, after setting the Slurm account:

```bash
mkdir -p logs
sbatch array/read_from_csv/bs_vars_from_csv.slurm
```

Logs are `logs/bs_vars_from_csv/ARRAY_ID_TASK_ID.out` relative to the repository root. Results are
`array/read_from_csv/output/ARRAY_ID/results_task_TASK_ID.csv`.

On your own computer, from the repository root:

```bash
Rscript --vanilla array/read_from_csv/bs_vars_from_csv.R
```

Outside of Slurm there is no task ID, so the script uses row 1 (`5,2`). Local
results go to `array/read_from_csv/output/local-parameters/results_task_1.csv`,
overwritten on reruns. This extension is separate from the bootstrap combine workflow.
