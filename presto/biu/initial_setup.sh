#!/usr/bin/env bash

# -x: Print each command before execution (trace mode)
# -e: Exit immediately on command failure (non-zero exit code)
# -u: Treat unset variables as errors instead of expanding to empty string
# -o pipefail: Return the exit code of the first failing command in a pipeline
set -xeuo pipefail

cd ../scripts

export PRESTO_DATA_DIR=/raid/knataraj/datasets
cp -r ${PRESTO_DATA_DIR}/hive_metastore ../docker/.hive_metastore

# Removes BuildKit (Docker's modern build engin) cache mounts specifically --
# the caches created by RUN --mount=type=cache directives in your Dockerfile.
# These cache mounts are how BuildKit persists directories (like /root/.cache/pip, /root/.cargo/registry, etc.)
# across builds so that package managers don't re-download everything on each build.
# Over time they can grow quite large.
# docker builder prune on its own clears the entire BuildKit build cache (intermediate layers, cache mounts, source snapshots, etc.).
# --filter type=exec.cachemount narrows the scope to only the RUN --mount=type=cache entries, leaving other cached build layers intact.
docker builder prune --filter type=exec.cachemount

./build_centos_deps_image.sh --no-cache
./start_native_gpu_presto.sh

