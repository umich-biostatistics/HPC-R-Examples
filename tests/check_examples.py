"""Maintainer checks: python3 tests/check_examples.py (requires R)."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="hpc-r-check-") as tmp:
    root = Path(tmp)
    for folder in ("shared", "simple", "multicore", "array", "workflow"):
        shutil.copytree(ROOT / folder, root / folder,
                        ignore=shutil.ignore_patterns("output", "summary", "*.out"))
    env = {k: v for k, v in os.environ.items() if not k.startswith("SLURM_")}
    helper = (root / "shared/bootstrap.R").read_text()

    def run(folder, script, extra=None, success=True):
        result = subprocess.run(["Rscript", "--vanilla", script], cwd=root / folder,
                                env=dict(env, **(extra or {})), capture_output=True, text=True)
        assert (result.returncode == 0) == success, result.stdout + result.stderr

    def csv(folder):
        return (root / folder / "bootstrap_means.csv").read_text()

    for iterations, tasks in ((7, 1), (7, 4), (2, 4)):
        (root / "shared/bootstrap.R").write_text(helper.replace(
            "n_observations <- 5000", "n_observations <- 30").replace(
            "n_bootstrap <- 1000", f"n_bootstrap <- {iterations}"))
        run("simple", "bs_simple.R")
        expected = csv("simple/output/local-serial")
        run("simple", "bs_simple.R", {"SLURM_JOB_ID": "9999999999"})
        assert expected == csv("simple/output/9999999999")
        run("multicore", "bs_multicore.R", {"SLURM_CPUS_PER_TASK": str(tasks)})
        assert expected == csv("multicore/output/local-multicore")
        array_id = f"test-{iterations}-{tasks}"
        for task in range(1, tasks + 1):
            run("array", "bs_array.R", {"SLURM_ARRAY_JOB_ID": array_id,
                "SLURM_ARRAY_TASK_ID": str(task), "SLURM_ARRAY_TASK_COUNT": str(tasks)})
        run("array/combine", "combine_csv.R", {"ARRAY_JOB_ID": array_id})
        assert expected == csv(f"array/output/{array_id}")
    run("array/combine", "combine_csv.R", success=False)
    (root / "shared/bootstrap.R").write_text(helper.replace(
        "n_observations <- 5000", "n_observations <- 30").replace(
        "n_bootstrap <- 1000", "n_bootstrap <- 7"))
    run("array/combine", "combine_csv.R", {"ARRAY_JOB_ID": "test-7-4"})
    target = root / "array/output/test-7-4/bootstrap_results_1.csv"
    original = target.read_text()
    target.write_text(original + original.splitlines()[1] + "\n")
    run("array/combine", "combine_csv.R", {"ARRAY_JOB_ID": "test-7-4"}, success=False)
    target.unlink()
    run("array/combine", "combine_csv.R", {"ARRAY_JOB_ID": "test-7-4"}, success=False)

    # Inject a worker failure and confirm cleanup closes socket connections.
    script = (root / "multicore/bs_multicore.R").read_text().split("time <- system.time")[0]
    script += '''
bootstrap_one <- function(...) stop("injected failure")
tryCatch(run_multicore(), error = function(e) NULL)
stopifnot(!any(showConnections(all = TRUE)[, "class"] == "sockconn"))
'''
    (root / "multicore/check_cleanup.R").write_text(script)
    run("multicore", "check_cleanup.R")

    # Capture submissions without contacting Slurm.
    bin_dir = root / "bin"
    bin_dir.mkdir()
    stub = bin_dir / "sbatch"
    stub.write_text('#!/bin/bash\nprintf "%s\\n" "$*" >> "$SUBMIT_LOG"\necho "12345;cluster"\n')
    stub.chmod(0o755)
    log = root / "submissions.txt"
    subprocess.run(["bash", "array_workflow.sh"], cwd=root / "workflow", check=True,
        env=dict(env, PATH=f"{bin_dir}:{env['PATH']}", SUBMIT_LOG=str(log)))
    lines = log.read_text().splitlines()
    assert len(lines) == 2
    assert "--dependency=afterok:12345" in lines[1]
    assert "--export=ALL,ARRAY_JOB_ID=12345" in lines[1]
print("PASS: matching results, uneven/empty tasks, incomplete results, cleanup, workflow")
