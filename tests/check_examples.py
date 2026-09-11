"""Maintainer checks: python3 tests/check_examples.py (requires R and parallelly)."""
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
    env["R_PARALLELLY_AVAILABLECORES_MAX"] = "4"
    helper = (root / "shared/bootstrap.R").read_text()

    def run(script, extra=None, success=True, args=()):
        result = subprocess.run(["Rscript", "--vanilla", script, *args], cwd=root,
                                env=dict(env, **(extra or {})), capture_output=True, text=True)
        assert (result.returncode == 0) == success, result.stdout + result.stderr

    def csv(folder):
        return (root / folder / "bootstrap_means.csv").read_text()

    for iterations, tasks in ((7, 1), (7, 4), (2, 4)):
        (root / "shared/bootstrap.R").write_text(helper.replace(
            "n_observations <- 50000", "n_observations <- 30").replace(
            "n_bootstrap <- 10000", f"n_bootstrap <- {iterations}"))
        run("simple/bs_simple.R")
        expected = csv("simple/output/local-serial")
        run("simple/bs_simple.R", {"SLURM_JOB_ID": "9999999999"})
        assert expected == csv("simple/output/9999999999")
        run("multicore/bs_multicore.R", {"SLURM_CPUS_PER_TASK": str(tasks)})
        assert expected == csv("multicore/output/local-multicore")
        array_id = f"test-{iterations}-{tasks}"
        for task in range(1, tasks + 1):
            run("array/bs_array.R", {"SLURM_ARRAY_JOB_ID": array_id,
                "SLURM_ARRAY_TASK_ID": str(task), "SLURM_ARRAY_TASK_COUNT": str(tasks)})
        run("array/combine/combine_csv.R", {"ARRAY_JOB_ID": array_id})
        assert expected == csv(f"array/output/{array_id}")
        # Outputs must stay in example folders, not the repository root.
        assert not (root / "output").exists()
    run("array/combine/combine_csv.R", success=False)
    (root / "shared/bootstrap.R").write_text(helper.replace(
        "n_observations <- 50000", "n_observations <- 30").replace(
        "n_bootstrap <- 10000", "n_bootstrap <- 7"))
    run("array/combine/combine_csv.R", {"ARRAY_JOB_ID": "test-7-4"})
    target = root / "array/output/test-7-4/bootstrap_results_1.csv"
    original = target.read_text()
    target.write_text(original + original.splitlines()[1] + "\n")
    run("array/combine/combine_csv.R", {"ARRAY_JOB_ID": "test-7-4"}, success=False)
    target.unlink()
    run("array/combine/combine_csv.R", {"ARRAY_JOB_ID": "test-7-4"}, success=False)

    run("array/read_from_csv/vars_from_csv.R", args=("5", "2"))
    assert (root / "array/read_from_csv/output/local-parameters/results_task_1.csv").exists()
    # Sourcing in an IDE uses the repository root as the working directory too.
    subprocess.run(["Rscript", "--vanilla", "-e", 'source("simple/bs_simple.R")'],
                   cwd=root, env=env, check=True, capture_output=True)

    # Inject a worker failure and confirm cleanup closes socket connections.
    script = (root / "multicore/bs_multicore.R").read_text().split("time <- system.time")[0]
    script += '''
bootstrap_one <- function(...) stop("injected failure")
tryCatch(run_multicore(), error = function(e) NULL)
gc()  # parallelly autoStop finalizes workers when their cluster is collected.
stopifnot(!any(showConnections(all = TRUE)[, "class"] == "sockconn"))
'''
    (root / "multicore/check_cleanup.R").write_text(script)
    run("multicore/check_cleanup.R", {"SLURM_CPUS_PER_TASK": "1"})

    # Capture submissions without contacting Slurm.
    bin_dir = root / "bin"
    bin_dir.mkdir()
    stub = bin_dir / "sbatch"
    stub.write_text('#!/bin/bash\nprintf "%s\\n" "$*" >> "$SUBMIT_LOG"\necho "12345"\n')
    stub.chmod(0o755)
    # Run copied batch scripts like Slurm does, with a stub module and real R.
    module = bin_dir / "module"
    module.write_text("#!/bin/bash\nexit 0\n")
    module.chmod(0o755)
    for folder, batch in (("simple", "bs_simple.slurm"), ("multicore", "bs_multicore.slurm"),
                          ("array", "bs_array.slurm"), ("array/combine", "combine_csv.slurm"),
                          ("array/read_from_csv", "vars_from_csv.slurm")):
        copied_batch = root / "copied_batch.sh"
        copied_batch.write_text((root / folder / batch).read_text())
        batch_env = dict(env, PATH=f"{bin_dir}:{env['PATH']}",
            SLURM_CPUS_PER_TASK="1", SLURM_JOB_ID="12345",
            SLURM_ARRAY_JOB_ID="batch-check", SLURM_ARRAY_TASK_ID="1",
            SLURM_ARRAY_TASK_COUNT="1", ARRAY_JOB_ID="batch-check")
        # Bash does not interpret #SBATCH: check the directive and emulate Slurm
        # opening the log before starting the script from the repository root.
        batch_text = copied_batch.read_text()
        output = next(line.split("=", 1)[1] for line in batch_text.splitlines()
                      if line.startswith("#SBATCH --output="))
        assert output == ("logs/%x-%A_%a.out" if "#SBATCH --array=" in batch_text
                          else "logs/%x-%j.out")
        job_name = next(line.split("=", 1)[1] for line in batch_text.splitlines()
                        if line.startswith("#SBATCH --job-name="))
        logfile = output.replace("%x", job_name).replace("%j", "12345").replace(
            "%A", "batch-check").replace("%a", "1")
        (root / "logs").mkdir(exist_ok=True)
        with (root / logfile).open("w") as log_handle:
            result = subprocess.run(["bash", str(copied_batch)], cwd=root,
                env=batch_env, stdout=log_handle, stderr=subprocess.STDOUT)
        assert result.returncode == 0, (root / logfile).read_text()
        assert (root / logfile).stat().st_size > 0
    log = root / "submissions.txt"
    subprocess.run(["bash", "workflow/array_workflow.sh"], cwd=root, check=True,
        env=dict(env, PATH=f"{bin_dir}:{env['PATH']}", SUBMIT_LOG=str(log)))
    lines = log.read_text().splitlines()
    assert len(lines) == 2
    assert "--dependency=afterok:12345" in lines[1]
    assert "--export=ALL,ARRAY_JOB_ID=12345" in lines[1]
print("PASS: matching results, uneven/empty tasks, incomplete results, cleanup, repository-root paths, batch scripts, workflow")
