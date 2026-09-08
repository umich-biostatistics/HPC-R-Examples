# Optional: different inputs per array task

Unlike the main bootstrap array, this example intentionally gives tasks different
inputs. `params.csv` has no header: each row contains a normal-distribution mean
and a positive standard deviation. The three rows are `5,2`, `5,4`, and `10,2`.

The batch script reads the row selected by the task ID and passes two numbers to
R. R generates 1,000 samples and reports their sample mean and standard deviation.
Use this simple two-number format and keep `--array=1-3` matched to the row count.

From this directory, after setting the Slurm account:

```bash
sbatch vars_from_csv.slurm
```

Logs are `param_array-ARRAY_ID_TASK_ID.out`. Results are
`output/ARRAY_ID/results_task_TASK_ID.csv`.

On your own computer, from this directory:

```bash
Rscript --vanilla vars_from_csv.R 5 2
```

Local results go to `output/local-parameters/results_task_1.csv`, overwritten on
reruns. This extension is separate from the bootstrap combine workflow.
