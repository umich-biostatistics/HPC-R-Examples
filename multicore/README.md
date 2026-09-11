# Multicore bootstrap

Follow the [main lesson](../README.md). Submit from the repository root:

```bash
mkdir -p logs
sbatch multicore/bs_multicore.slurm
```

One Slurm job requests four CPUs on one node. R creates separate worker processes
and distributes the same bootstrap iterations using `parallel::parLapply()`.
`parallelly::availableCores()` detects available CPUs, respecting Slurm limits,
and `parallelly::makeClusterPSOCK()` creates the workers. `parallelly` extends
R's bundled `parallel` package; `parLapply()` still performs the computation.
`autoStop = TRUE` cleans up workers when R garbage-collects the cluster object.

Install `parallelly` once in an R session using the same R module as your jobs:

```r
install.packages("parallelly", repos = "https://cloud.r-project.org")
```

Accept the personal-library prompt if needed. Package installation is separate
from running the batch job.

On your own computer, from the repository root:

```bash
R_PARALLELLY_AVAILABLECORES_MAX=2 Rscript --vanilla multicore/bs_multicore.R
```

This caps the local run at two workers. Without the cap, `availableCores()` uses
the detected CPU availability. See the [parallelly documentation](https://parallelly.futureverse.org/)
for how resource detection and cluster creation work. Results go to
`multicore/output/local-multicore/bootstrap_means.csv`, overwritten on reruns. Under Slurm,
the job ID replaces `local-multicore`. The summary prints to the terminal or batch
log, and timing includes worker startup, computation, and collection.
