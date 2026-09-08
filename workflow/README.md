# Optional: submit the array and combine as a workflow

After completing the manual [array lesson](../README.md), configure the account
in both array and combine submission files, then run from this directory:

```bash
bash array_workflow.sh
```

The script submits the array, captures its numeric ID, and passes that exact ID
to the combine job with `--export=ALL,ARRAY_JOB_ID=...`. The `afterok` dependency
allows combination only after every array task succeeds. It handles the optional
`;cluster` suffix returned by `sbatch --parsable` and stops if submission fails.
It resolves directories relative to its own location.

Monitor with `squeue -u "$USER"` and inspect final states with
`sacct -j JOB_ID --format=JobID,State,ExitCode,Elapsed,AllocCPUS,MaxRSS`.
If the array fails, the combine job cannot satisfy its dependency; inspect the
array logs and cancel the pending combine job with `scancel COMBINE_JOB_ID`
before submitting a corrected workflow. If combine submission itself fails,
the printed array ID still identifies the running array; inspect or cancel it.

The final CSV is `array/output/ARRAY_ID/bootstrap_means.csv`, relative to the
repository root. The summary prints in the combine job's `.out` log.
Logs remain in the array and combine submission directories. A dependency controls
when a job runs; explicit ID forwarding controls which results it reads.
