# HPC R Examples

> [!NOTE]
> This branch contains slurm files specific to the **Great Lakes.**
>
> Check branches for other HPC Clusters or environments

## Summary

This repository provides example R and SLURM scripts demonstrating several methods for running bootstrap analyses on an HPC cluster. The examples range from basic single-core jobs to parallel and array-based workflows, including automated result combination.

## Folder Structure & Scripts

- **simple/**: Basic single-core bootstrap example
  - `bs_simple.R`: R script for bootstrap analysis
  - `bs_simple.slurm`: SLURM script to submit the job

- **parallel/**: Multi-core parallel bootstrap example
  - `bs_parallel.R`: Uses the `parallelly` and `parallel` R packages to distribute work across available cores
  - `bs_parallel.slurm`: SLURM script to request multiple cores

- **array/**: Job array example for distributing bootstrap tasks
  - `bs_array.R`: R script that runs a portion of the bootstrap, using SLURM array task IDs
  - `bs_array.slurm`: SLURM array job script
  - **combine/**: Combine results from array jobs
    - `combine_csv.R`: R script to merge CSV outputs from all array jobs
    - `combine_csv.slurm`: SLURM script to run the combine step
  - **read_from_csv/**: Example of a SLURM array job where each task reads parameters from a CSV file
    - `vars_from_csv.R`: Sample R script that processes parameters from a CSV file
    - `vars_from_csv.slurm`: SLURM batch script that reads CSV parameters for each array task
    - `params.csv`: Example CSV file with parameter sets
    - `README.md`: Details on using CSV input with SLURM array jobs

- **workflow/**: Workflow automation
  - `array_workflow.sh`: Bash script to submit the array job and then the combine job with dependency handling
  - `README.md`: Details on the workflow usage

## Example Job Types

| Job Type | Definition                                                                                         |
|----------|----------------------------------------------------------------------------------------------------|
| simple   | A simple R and SLURM script that shows how to run your code on the cluster with no frills.         |
| parallel | How to run the same simple job, but use multiple cores to split up the work.                       |
| array    | Split the simple job into a job array, spreading the work across multiple CPUs running in parallel |
| workflow | Automate running the array and combine jobs in sequence, ensuring results are merged after all tasks complete |

## Usage

> [!TIP]
> The parallel and combine examples will use the UMICH CRAN mirror to install required R packages if not already installed.

1. Connect to a terminal session on `greatlakes.arc-ts.umich.edu`
2. `cd` into the desired directory
3. `git clone` this repository
4. `cd` into one of the example folders (e.g., `simple`, `parallel`, `array`)
5. Update `.slurm` files with the appropriate SLURM account:
   - `find . -type f -name "*.slurm" -exec sed -i 's/SLURM_ACCOUNT/your_account_here/g' {} +`
6. Submit a job: `sbatch bs_EXAMPLE.slurm` (replace EXAMPLE with the appropriate name)
7. Use `sq` to view your job queue
8. Once complete, use `my_job_statistics JOB_ID` (replace JOB_ID with your job's ID)

### Workflow Automation

To automate running the array and combine jobs:

```bash
cd workflow
bash array_workflow.sh
```

This will submit the array job, then automatically submit the combine job after all array tasks finish. See `workflow/README.md` for more details.

---

For more information on each example, see the README files in the respective subfolders.
