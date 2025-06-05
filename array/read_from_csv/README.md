# SLURM Array Job with CSV Parameter Input

This example demonstrates how to run a SLURM array job where each task reads parameters from a CSV file and passes them to an R script. It is useful for running parameter sweeps or simulations with varying input values.

## Files Included
- `vars_from_csv.slurm` - SLURM batch script that reads CSV parameters
- `vars_from_csv.R` - Sample R script that processes the parameters
- `params.csv` - Example CSV file with 3 parameter sets
- `logs/` - Directory for SLURM output files

## How It Works
- **CSV Input**: The script expects a CSV file (no header by default) with at least two columns, e.g.:
  ```
  0.01,0.5
  0.02,0.7
  0.005,1.2
  ```
- **SLURM Array**: Each array task reads a different line from the CSV, extracting the first two columns as variables (`sigma` and `beta_mag`).
- **R Script Execution**: The extracted values are passed as command-line arguments to an R script.
- **Unique Results**: Each task uses its SLURM array task ID for random seeding and output file naming.

## Quick Start

To test the example:

```bash
sbatch vars_from_csv.slurm
```

This will run 3 array tasks (one for each row in `params.csv`) and produce:

- SLURM output logs in `logs/output_<jobid>_<taskid>.out`
- Result CSV files: `results_task_1.csv`, `results_task_2.csv`, `results_task_3.csv`

## Usage
1. **Edit the Script**
   - Set `CSV_FILE` to the path of your parameter CSV file (default: `params.csv`)
   - Set the `Rscript` command and script name as needed (default: `vars_from_csv.R`)
   - Adjust the `#SBATCH --array=1-3` line to match the number of rows in your CSV

2. **CSV File Format**
   - Default: No header, comma-separated values
   - If your CSV has a header, either:
     - Change the array to start at 2 (e.g., `#SBATCH --array=2-4`) and subtract 1 from the index, or
     - Use `sed -n "$(( SLURM_ARRAY_TASK_ID + 1 ))p"` to skip the header

3. **Submit the Job**

   ```bash
   sbatch vars_from_csv.slurm
   ```

4. **Output**
   - Job output (console information) will be written to `logs/output_<jobid>_<taskid>.out`
   - R script results will be saved to `results_task_<taskid>.csv`

## Example R Script Features

The included `vars_from_csv.R` demonstrates:

- Robust argument parsing with help and error handling
- SLURM-aware random seeding using `SLURM_ARRAY_TASK_ID`
- Unique output file naming per task
- Simple statistical simulation with the input parameters

## Tips

- **Delimiter**: If your CSV uses tabs or another delimiter, adjust the `IFS` and `read` statement accordingly
- **More Columns**: To extract more columns, add more variables to the `read` statement
- **Module Loading**: The script loads the R module (`module load R`). Remove or modify this line if R is already available or if you use a different environment setup
- **Debugging**: Add `set -x` at the top of the script for verbose output during debugging

## Troubleshooting

- Ensure the number of array tasks matches the number of data rows in your CSV
- Ensure the `logs/` directory exists before submitting the job
- Each R script should use unique output file names (the example uses SLURM task ID)
- Check file paths for both the CSV and R script
- Review SLURM output logs in `logs/` for errors
