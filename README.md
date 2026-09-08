# One R analysis, three ways to run it on Great Lakes

These examples introduce SPH students with basic R experience to batch computing.
Each example performs the **same bootstrap analysis**. Only how the work runs changes.

| Style | How the work runs | How results are collected |
|---|---|---|
| Serial (`simple/`) | One R process runs all iterations | The same R process saves the results |
| Multicore (`multicore/`) | One job uses four R workers on one node | The coordinating R process collects results |
| Array (`array/`) | Four independent single-core jobs each run some iterations | A separate combine job reads their files |

```text
Serial:     one R process → all iterations → results
Multicore:  one R process → four workers → collect results in R
Array:      Slurm → four independent jobs → partial files → combine job
```

Requesting more CPUs does not automatically make R code parallel. Array tasks
may run at different times, on the same node or on different nodes.

## The analysis

Read `shared/bootstrap.R` first. It creates 5,000 simulated observations and defines
one bootstrap iteration: sample the full dataset **with replacement** and calculate
its mean. Replacement allows an observation to appear more than once.

Each example runs 1,000 iterations. The 2.5th and 97.5th percentiles of the resulting
means give a percentile 95% confidence interval. Each iteration uses its own fixed
seed, so all three approaches produce matching results with the same R version and
settings. The job ID only names output folders.

## 1. Get ready

```bash
ssh YOUR_UNIQNAME@greatlakes.arc-ts.umich.edu
git clone https://github.com/umich-biostatistics/HPC-R-Examples.git
cd HPC-R-Examples
```

Replace `SLURM_ACCOUNT` in the `.slurm` files with your allocation name. This
branch uses Great Lakes's `standard` partition and `R/4.4` module. Check the module
with `module spider R/4.4`; use the same available R version in every example.
No additional R packages are needed.

Submit from the example's directory, as shown below. Run cluster calculations
through Slurm rather than directly on the login node.

## 2. Serial: one process

```bash
cd simple
sbatch bs_simple.slurm
```

Slurm prints a job ID. Submission returns immediately; the job may wait in a queue.
Use `squeue -u "$USER"` to check progress. After completion, replace `JOB_ID` below
with the printed number:

```bash
cat bs_simple-JOB_ID.out
head output/JOB_ID/bootstrap_means.csv
cd ..
```

The log shows the mean, confidence interval, and runtime. The CSV contains
`iteration` and `bootstrap_mean`. Read `bs_simple.R`: `lapply()` runs every iteration
in one R process.

## 3. Multicore: workers within one job

```bash
cd multicore
sbatch bs_multicore.slurm
```

After completion, read `bs_multicore-JOB_ID.out` and
`output/JOB_ID/bootstrap_means.csv`. Then return to the repository root with `cd ..`.

Compare the R scripts: `parLapply()` replaces `lapply()`. R creates workers, sends
them the function and full dataset, and collects their answers. The Slurm file
requests four CPUs; `SLURM_CPUS_PER_TASK` tells R how many workers to create.
Workers have separate memory. The script stops them when finished.

## 4. Array: independent jobs and a combine step

```bash
cd array
sbatch bs_array.slurm
```

The Slurm file defines `--array=1-4`. Each task runs a separate copy of the R
script. Task 1 handles iterations 1, 5, 9, …; task 2 handles 2, 6, 10, …, and so on.
Every task uses the **same full dataset**. We split iterations, not observations.

After all tasks succeed, inspect a partial CSV and submit the combine job.
Replace `ARRAY_ID` with the array job ID:

```bash
head output/ARRAY_ID/bootstrap_results_1.csv
sacct -j ARRAY_ID --format=JobID,State,ExitCode
cd combine
sbatch --export=ALL,ARRAY_JOB_ID=ARRAY_ID combine_csv.slurm
```

After combination finishes, its `combine_csv-JOB_ID.out` log shows the final
confidence interval. The complete CSV is `../output/ARRAY_ID/bootstrap_means.csv`.
The combine script stacks the partial results, checks that all iteration IDs are
present exactly once, and calculates the interval from all means together.
Return to the repository root with `cd ../..`.

## Compare and explore

From the repository root, substitute your actual job IDs:

```bash
diff simple/output/SERIAL_ID/bootstrap_means.csv multicore/output/MULTICORE_ID/bootstrap_means.csv
diff simple/output/SERIAL_ID/bootstrap_means.csv array/output/ARRAY_ID/bootstrap_means.csv
```

No output from `diff` means the files match.

- Does requesting four CPUs change ordinary R code?
- Does array task 2 receive different observations?
- Where are results collected in each approach?
- Why might a small multicore job take longer?

Worker startup and transferring data take time. Multicore timing includes these
costs; each array task reports only its own computation time. Neither adding task
times nor comparing one task to the whole serial job measures overall speedup.

Monitor with `squeue -u "$USER"`. Inspect a completed job with
`sacct -j JOB_ID --format=JobID,State,ExitCode,AllocCPUS,Elapsed,MaxRSS`.
Cancel a job with `scancel JOB_ID`. If a job fails, read its `.out` log first.
Array logs are named `bootstrap_array-ARRAY_ID_TASK_ID.out`.

To try more work, edit the two settings at the top of `shared/bootstrap.R`.
An optional larger experiment uses 50,000 observations and 50,000 iterations;
increase the requested time after measuring a smaller run. Keep settings unchanged
between the three runs and array combination. The five-minute, 1 GB requests
are starting points pending measurements on Great Lakes.

## Optional material

- [Serial local run](simple/README.md)
- [Multicore local run](multicore/README.md)
- [Array local simulation](array/README.md)
- [Automatic array → combine workflow](workflow/README.md)
- [Different parameters per array task](array/read_from_csv/README.md)

For maintainers: `python3 tests/check_examples.py` runs small local comparisons
in a temporary copy (requires R and Python 3). Cluster resource sizing and the
beginner walkthrough still need validation on Great Lakes.
