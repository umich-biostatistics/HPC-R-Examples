#!/bin/bash
array=$(sbatch ../Saving_Array_Data/savearray.slurm | awk '{print $NF}')
sbatch --dependency=afterok:$array combine.slurm
