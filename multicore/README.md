# Multicore bootstrap example

This folder contains a small example R script that performs a bootstrap analysis in parallel using a PSOCK cluster. It is intended as a lightweight demo for running parallel R jobs on a multi-core node (for example, on an HPC cluster managed by Slurm).

## Files

- `bs_multicore.R` — main R script that:
  - generates a sample dataset (50,000 observations from a normal distribution),
  - splits bootstrap work across available CPU cores using `parallelly` and `parallel`,
  - runs a total of 50,000 bootstrap iterations (divided evenly across cores),
  - computes a 95% bootstrap confidence interval for the sample mean,
  - saves summary output and detailed bootstrap means to disk.

## Usage

When running on a Slurm-managed cluster, the script expects the environment variable `SLURM_JOB_ID` to be set (the script uses it to create job-specific output directories). A simple Slurm submission file `bs_multicore.slurm` is included in this folder; submit it with:

    sbatch bs_multicore.slurm

### What the script does (contract)

- Inputs: none required; the script generates its own example data. In real use, replace the sample data generation with code that loads your dataset.

- Outputs:
  - `summary/<SLURM_JOB_ID>/multicore_bootstrap_results.txt` — a plain-text summary including the original mean, bootstrap mean, 95% CI, cores used, total iterations, and runtime.

  - `output/<SLURM_JOB_ID>/csv/multicore_bootstrap_means.csv` — CSV containing each bootstrap mean value.

- Success criteria: script completes without error, results files are written to the `summary` and `output` subdirectories below the working directory.

### Key implementation notes

- The script uses `parallelly::availableCores()` to decide how many worker processes to create and divides the total number of bootstrap iterations (`n_bootstrap = 50000`) evenly across chunks (one chunk per core).

- A PSOCK cluster is created with `parallelly::makeClusterPSOCK()` and `parLapply()` is used to parallelize work.

- Reproducibility: `set.seed(job_id)` is set globally, and each chunk uses `set.seed(job_id + chunk_id)` so results are reproducible across runs when the number of chunks and data are unchanged.

- The script installs `parallelly` if it is not available. It uses a specific CRAN mirror used internally at the University of Michigan; you may want to change the `repos` argument to a public CRAN mirror (for example, `https://cloud.r-project.org`) if you run outside that environment.

### Suggested edits for real analyses

- Replace the example data generation (the `data <- rnorm(...)` line) with code to read your input data file(s).

- Make `n_bootstrap` and the random seed configurable via command-line arguments or environment variables (for example, using `commandArgs(trailingOnly = TRUE)` or the `optparse` package).

- Add error handling around cluster creation and export; ensure cluster is stopped on error.

- If `n_bootstrap` is not divisible by the number of cores, adjust logic so each chunk gets an integer count (use `ceiling()`/`floor()` and combine or pad as needed).

### Where outputs are written

- Summary: `./summary/<SLURM_JOB_ID>/multicore_bootstrap_results.txt`

- Detailed CSV: `./output/<SLURM_JOB_ID>/csv/multicore_bootstrap_means.csv`

### Minimal example: run locally

1. From this directory run:

       Rscript bs_multicore.R

2. Inspect results (replace `<JOBID>` with the printed job id or check the `summary/` directory):

       cat summary/<JOBID>/multicore_bootstrap_results.txt
       head -n 10 output/<JOBID>/csv/multicore_bootstrap_means.csv

## License / attribution

This example is intended for demonstration and teaching. Feel free to adapt it for your own workflows.
