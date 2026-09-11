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

Read `shared/bootstrap.R` first. It creates 50,000 simulated observations and defines
one bootstrap iteration: sample the full dataset **with replacement** and calculate
its mean. Replacement allows an observation to appear more than once.

Each example runs 10,000 iterations. The 2.5th and 97.5th percentiles of the resulting
means give a percentile 95% confidence interval. The job ID only names output folders.

### Seeding matters in parallel and batch code

Random number generators are only reproducible if you control the seed. In serial
code, calling `set.seed()` once at the top is enough. Split the same work across
workers or Slurm tasks, though, and a single shared seed no longer guarantees the
same answer: a worker may run a different subset of iterations depending on
timing, task count, or scheduling, so "the same seed" can produce different draws
on different runs.

A common but fragile fix is to seed by worker or task ID instead (e.g.
`set.seed(task_id)`). That reintroduces the same problem one level up: which task
or worker handles a given piece of work can change if you request a different
number of tasks or workers, so results still depend on how the job happened to be
split, not just on the data and settings.

These examples avoid both problems by seeding **per iteration**, keyed to a global
iteration number that does not depend on which task or worker runs it (see
`shared/bootstrap.R` and `bootstrap_one()`). Iteration 4237 draws the same
resample whether it runs serially, on worker 3 of 8, or on array task 2 of 4. That
is why the serial, multicore, and array outputs match exactly — see
[Compare and explore](#compare-and-explore) below — and it will keep matching even
if you change the number of workers or array tasks.

## 1. Get ready

```bash
ssh YOUR_UNIQNAME@greatlakes.arc-ts.umich.edu
git clone https://github.com/umich-biostatistics/HPC-R-Examples.git
cd HPC-R-Examples
mkdir -p logs
```

Replace `SLURM_ACCOUNT` in the `.slurm` files with your allocation name. This
branch uses Great Lakes's `standard` partition and `R/4.4` module. Check the module
with `module spider R/4.4`; use the same available R version in every example.
The multicore example needs `parallelly`. Before submitting it, install the package
once from an R session using the same R module:

```r
install.packages("parallelly", repos = "https://cloud.r-project.org")
```

Accept R's offer to create a personal library if needed. The batch script does not
install packages. Serial and array examples need only base R.

**Use the repository root (`HPC-R-Examples/`) as the working directory for all
batch submissions and local R runs.** All script, input, and output paths are
relative to this directory; the R scripts do not detect or change it.
Create `logs/` before submitting: Slurm opens the log before running your script.
The examples use `#SBATCH --output=logs/%x/%j.out` directives; `%x`
is the job name and `%j` is the job ID. Array logs use `%A_%a` for the array and
task IDs. Standard output and error messages share the same log.

R results go in each example's `output/` folder. Run the local examples from the
repository root on your own computer or an allocated compute session. On the
cluster, use Slurm rather than computing on the login node.

## 2. Serial: one process

```bash
sbatch simple/bs_simple.slurm
```

Slurm prints a job ID. Submission returns immediately; the job may wait in a queue.
Use `squeue -u "$USER"` to check progress. After completion, replace `JOB_ID` below
with the printed number:

```bash
cat logs/bs_simple/JOB_ID.out
head simple/output/JOB_ID/bootstrap_means.csv
```

The log shows the mean, confidence interval, and runtime. The CSV contains
`iteration` and `bootstrap_mean`. Read `bs_simple.R`: `lapply()` runs every iteration
in one R process.

## 3. Multicore: workers within one job

```bash
sbatch multicore/bs_multicore.slurm
```

After completion, read `logs/bs_multicore/JOB_ID.out` and
`multicore/output/JOB_ID/bootstrap_means.csv`.

Compare the R scripts: `parLapply()` replaces `lapply()`. R creates workers, sends
them the function and full dataset, and collects their answers. The Slurm file
requests four CPUs; `parallelly::availableCores()` detects the allocation, and
`parallelly::makeClusterPSOCK()` creates the workers. The computation still uses
`parallel::parLapply()` from R's bundled `parallel` package.
Workers have separate memory. The script stops them when finished.

## 4. Array: independent jobs and a combine step

```bash
sbatch array/bs_array.slurm
```

The Slurm file defines `--array=1-4`. Each task runs a separate copy of the R
script. Task 1 handles iterations 1, 5, 9, …; task 2 handles 2, 6, 10, …, and so on.
Every task uses the **same full dataset**. We split iterations, not observations.

After all tasks succeed, inspect a partial CSV and submit the combine job.
Replace `ARRAY_ID` with the array job ID:

```bash
head array/output/ARRAY_ID/bootstrap_results_1.csv
sacct -j ARRAY_ID --format=JobID,State,ExitCode
sbatch --export=ALL,ARRAY_JOB_ID=ARRAY_ID array/combine/combine_csv.slurm
```

After combination finishes, its `logs/combine_csv/JOB_ID.out` log shows the final
confidence interval. The complete CSV is `array/output/ARRAY_ID/bootstrap_means.csv`.
The combine script stacks the partial results, checks that all iteration IDs are
present exactly once, and calculates the interval from all means together.

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
Array logs are named `logs/bs_array/ARRAY_ID_TASK_ID.out` from the root.
If no log appears, check that `logs/` exists and that you submitted from the
repository root.

To try more work, edit the two settings at the top of `shared/bootstrap.R`.
An optional larger experiment uses 50,000 observations and 50,000 iterations;
increase the requested time after measuring a smaller run. Keep settings unchanged
between the three runs and array combination. The three compute jobs request
15 minutes and 1 GB each; these are starting points pending measurements on
Great Lakes. The time limit allows a longer run but does not increase the work.
Aim for a serial run of 1–3 minutes and adjust `n_bootstrap` after measuring it.

## Optional material

- [Serial local run](simple/README.md)
- [Multicore local run](multicore/README.md)
- [Array local simulation](array/README.md)
- [Automatic array → combine workflow](array/workflow/README.md)
- [Different parameters per array task](array/read_from_csv/README.md)

For maintainers: `python3 tests/check_examples.py` runs small local comparisons
in a temporary copy (requires R, parallelly, and Python 3). Cluster resource sizing and the
beginner walkthrough still need validation on Great Lakes.
