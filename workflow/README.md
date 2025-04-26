# Job Array Combine CSV Workflow

This workflow automates the submission of bootstrap analysis jobs using Slurm's array capabilities followed by a combine job that processes the results. The combine script will only run after all array jobs have completed successfully.

## How It Works

The `array_workflow.sh` script:

1. Submits the bootstrap array job (`bs_array.slurm`) and captures its job ID
2. Submits the combine job (`combine_csv.slurm`) with a dependency on the successful completion of the array job
3. Displays the job IDs and workflow stages for monitoring

## Usage

```bash
./array_workflow.sh
```

or

```bash
bash array_workflow.sh
```

## Monitoring

After running the workflow, you can monitor the job status with the `sq` command. The workflow will create a directory structure under `array/output/` with a timestamp-based folder containing all bootstrap results and a `combined/` subdirectory for the final combined results.
