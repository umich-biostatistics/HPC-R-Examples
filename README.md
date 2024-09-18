# HPC R Examples

> [!NOTE]
> This branch contains slurm files specific to the **Great Lakes.**
> 
> Use `git clone -b GL_Bootstrap https://github.com/umich-biostatistics/HPC-R-Examples.git`

## Summary

These are example R and SLURM scripts that can be used to show various methods of running jobs on an HPC cluster.

The example performs a simple bootstrap analysis on a generated dataset. It's a basic example that doesn't require much computational power but can be time-consuming for large datasets or many bootstrap iterations.

## Examples

| Job Type     | Definition                                                                                         |
| ------------ | -------------------------------------------------------------------------------------------------- |
| simple       | A simple R and SLURM script that shows how to run your code on the cluster with no frills.         |
| parallel     | how to run the same simple job, but use multiple cores to split up the work.                       |
| array        | Split the simple job into a job array, spreading the work across multiple CPUs running in parallel |
