#!/bin/bash

#########################
### SBATCH Directives ###
#########################

# The name of the job
#SBATCH --job-name=example

# The name and location of the output file - the default directory is the 
# working directory, i.e. the one the job was submitted from.
# %x represents the job name, and %j represents the job number
# if you specify a directory, ensure it exists first with the mkdir -p command
# at the begging of your list of commands torwards the bottom of this file.
#SBATCH --output=%x-%j

## CPU Options ##
# You will not need to use all of these at the same time typically.
# See https://myumi.ch/mZJZE for an explainer on parallelization options

# Number of tasks to run
#SBATCH --ntasks=1

# Number of physical nodes (computers)
#SBATCH --nodes=1

# Number of tasks per node
#SBATCH --ntasks-per-node=1

# Number of CPUs for each task being run by your job
#SBATCH --cpus-per-task=1

# Memory per node
#SBATCH --mem=1g

# Maximum amount of time the job will be allowed to run
# Recommended formats:  MM:SS, HH:MM:SS, DD-HH:MM
#SBATCH --time=00:05:00

# E-Mail notifications - possible options: NONE, BEGIN, END, FAIL, REQUEUE, ALL
#SBATCH --mail-type=ALL

#####################################
### Your commands after this line ###
#####################################

# Load the R module (not required for Biostat Cluster, but won't hurt)
module load R

# Run the script in R Batch Mode
R CMD BATCH --no-save --no-restore script.R
