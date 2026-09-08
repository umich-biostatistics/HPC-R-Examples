# Serial bootstrap

Follow the [main lesson](../README.md). From this directory:

```bash
sbatch bs_simple.slurm
```

On your own computer with R installed, you can instead run:

```bash
Rscript --vanilla bs_simple.R
```

The summary prints to the terminal. Results go to
`output/local-serial/bootstrap_means.csv`; reruns overwrite this file.
Under Slurm, the job ID replaces `local-serial`, and the summary appears in the
`.out` log. The shared helper defines the data and analysis; this script shows
how `lapply()` executes all iterations serially.
