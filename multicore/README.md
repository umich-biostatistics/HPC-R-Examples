# Multicore bootstrap

Follow the [main lesson](../README.md). From this directory:

```bash
sbatch bs_multicore.slurm
```

One Slurm job requests four CPUs on one node. R creates separate worker processes
and distributes the same bootstrap iterations using `parallel::parLapply()`.
The bundled `parallel` package needs no installation. `on.exit()` stops workers
when the function returns, including on an error.

On your own computer, from this directory:

```bash
Rscript --vanilla bs_multicore.R  # one worker by default
SLURM_CPUS_PER_TASK=4 Rscript --vanilla bs_multicore.R
```

Use a worker count your computer supports. Results go to
`output/local-multicore/bootstrap_means.csv`, overwritten on reruns. Under Slurm,
the job ID replaces `local-multicore`. The summary prints to the terminal or batch
log, and timing includes worker startup, computation, and collection.
