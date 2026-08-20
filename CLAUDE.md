# CLAUDE.md

Workflow notes for Presto-GPU benchmarking.
General repo layout, build, and test docs live in [.claude/CLAUDE.md](.claude/CLAUDE.md).

## Working directory (on EC2)

```bash
cd presto/scripts        # upstream scripts
cd presto/scripts/biu    # local wrapper scripts (run_bench.sh, ...)
```

## Rebuild the worker after a Velox change

Velox source is the sibling checkout `../velox`. After editing it, rebuild and
restart only the native GPU worker:

```bash
cd presto/scripts/biu
./start_native_gpu_presto.sh -b worker
```

- `-b` / `--build` takes `coordinator` | `worker` | `all` (or `c` | `w` | `a`).
- Without `-b`, the image is only built if no local image exists.
- Add `--sccache` to use the distributed compile cache (requires `~/.sccache-auth/`;
  set up with `scripts/sccache/setup_sccache_auth.sh`).

## Run the benchmark

```bash
cd presto/scripts/biu
./run_bench.sh
```

Wraps `presto/scripts/run_benchmark.sh` and handles EC2 credentials.

## Stop the cluster

```bash
cd presto/scripts
./stop_presto.sh
```
