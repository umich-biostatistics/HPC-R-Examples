# Optional: automatically combine an array's results

First complete the manual steps in the [main lesson](../README.md). Then, from
the repository root, run:

```bash
bash workflow/array_workflow.sh
```

The script creates `logs/`, submits the array, and saves its job ID in a Bash
variable. It uses that ID in two ways when submitting the combine job:

- `--dependency=afterok:...` waits for all array tasks to succeed.
- `--export=ALL,ARRAY_JOB_ID=...` tells R which array's files to combine.

Read the short script to see these two submissions. Both batch scripts must have
your Slurm account configured. Monitor with `squeue -u "$USER"`.

Logs go in `logs/`. Combined results go in
`array/output/ARRAY_ID/bootstrap_means.csv`. If the array fails, inspect its logs
and cancel the waiting combine job with `scancel COMBINE_JOB_ID` before retrying.
