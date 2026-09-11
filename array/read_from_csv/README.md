# Optional: different inputs per array task

Unlike the main bootstrap array, this example intentionally gives tasks different
inputs. `params.csv` has no header: each row contains a normal-distribution mean
and a positive standard deviation. The three rows are `5,2`, `5,4`, and `10,2`.

The batch script reads the row selected by the task ID and passes two numbers to
R. R generates 1,000 samples and reports their sample mean and standard deviation.
Use this simple two-number format and keep `--array=1-3` matched to the row count.

From the repository root, after setting the Slurm account:

```bash
mkdir -p logs
sbatch array/read_from_csv/vars_from_csv.slurm
```

Logs are `logs/vars_from_csv/ARRAY_ID_TASK_ID.out` relative to the repository root. Results are
`array/read_from_csv/output/ARRAY_ID/results_task_TASK_ID.csv`.

On your own computer, from the repository root:

```bash
Rscript --vanilla array/read_from_csv/vars_from_csv.R 5 2
```

Local results go to `array/read_from_csv/output/local-parameters/results_task_1.csv`,
overwritten on reruns. This extension is separate from the bootstrap combine workflow.
