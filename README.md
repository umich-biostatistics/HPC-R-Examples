# HPC R Examples

> [!NOTE]
> This branch contains slurm files specific to the **Great Lakes.**
> 
> Check branches for other HPC Clusters or environments

## Summary

These are example R and SLURM scripts that can be used to show various methods of running jobs on an HPC cluster.

The examples perform a simple bootstrap analysis on a generated dataset. It's a basic example that doesn't require much computational power but can be time-consuming for large datasets or many bootstrap iterations.

## Examples

| Job Type | Definition                                                                                         |
|----------|----------------------------------------------------------------------------------------------------|
| simple   | A simple R and SLURM script that shows how to run your code on the cluster with no frills.         |
| parallel | how to run the same simple job, but use multiple cores to split up the work.                       |
| array    | Split the simple job into a job array, spreading the work across multiple CPUs running in parallel |

## Usage

> [!TIP]
> The Parallel example will used the UMICH CRAN mirror to install the `parallelly` package if not installed.

1. Connect to terminal session on `greatlakes.arc-ts.umich.edu`
2. `cd` into desired directory
3. `git clone`
4. `cd` into one of the examples
5. Update `.slurm` file with the appropraite SLURM account
   - `find . -type f -name "*.slurm" -exec sed -i 's/SLURM_ACCOUNT/your_account_here/g' {} +`
6. `sbatch bs_EXAMPLE.slurm` (replace EXAMPLE with proper name)
7. `sq` to view your job queue
8. Once complete, `my_job_statistics JOB_ID` (replace JOB_ID with that of your job)
