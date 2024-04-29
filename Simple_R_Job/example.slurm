#!/bin/bash

# The name of the job
#SBATCH --job-name=JOBNAME

# The name and location of the output file; this example format
# will put the output in your home directory and call the output
# file by the job name, a `-`, and finally the job number.  There
# are many options; see the sbatch man page, `filename pattern`
# section for more options and examples.  Make sure that the
# output directory exists *before* you submit the job!  Do *not*
# use any directory that is not available on all nodes, e.g., /tmp.

#SBATCH --output=/home/%u/%x-%j

##### Resources for your job

# number of physical nodes
#SBATCH --nodes=1

# number tasks (processes) per node; this will most commonly be the
# same number as the number of processors.  Each task will get one
# processor by default.
#SBATCH --ntasks-per-node=1

# memory per node
#SBATCH --mem=4g

#### Maximum amount of time the job will be allowed to run
####    Recommended formats:  MM:SS, HH:MM:SS, DD-HH:MM
#SBATCH --time=00:05:00

# Money matters; who pays
#SBATCH --account=test

# Which group of nodes (partition) should this job run in
#SBATCH --partition=standard

# Whom to send e-mail about the job; change to your e-mail address
#SBATCH --mail-user=username@umich.edu

# When to send e-mail: pick from NONE, BEGIN, END, FAIL, REQUEUE, ALL
#SBATCH --mail-type=NONE

# Your commands after this line

# Load the R module (not required for Biostat Cluster, but won't hurt)
module load R

R CMD BATCH --no-save --no-restore script.R
