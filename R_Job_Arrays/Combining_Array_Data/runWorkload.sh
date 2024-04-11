#!/bin/bash
array=$(sbatch savearray.slurm | awk '{print $NF}')
sbatch --dependency=afterok:$array combine.slurm
