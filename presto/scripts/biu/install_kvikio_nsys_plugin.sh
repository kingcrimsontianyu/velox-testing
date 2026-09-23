#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Build KvikIO's `kvikio_nic` Nsight Systems plugin and install it into the running native
# GPU worker container(s), so that `run_benchmark.sh -p` reports carry a NIC bandwidth
# timeline next to the CUDA/NVTX rows.
#
# The plugin is a standalone executable: it does not link libkvikio and only needs the NVTX
# headers, which ship with nsys inside the worker image. It is therefore compiled with the
# worker image's own gcc-toolset (and a static libstdc++) so the binary matches the
# container's glibc, independent of what the host runs.
#
# Run this after the cluster is up; the install lives in the container's writable layer, so
# it has to be redone whenever the worker container is recreated.
#
# Usage:
#   ./install_kvikio_nsys_plugin.sh [--kvikio-src DIR]
#
# Then profile as usual (see run_bench.sh):
#   export NSYS_PLUGIN_SEARCH_DIRS=/opt/nsys-plugins
#   export PROFILE_NSYS_START_ARGS='--enable=kvikio_nic,-d,eth0,-i,20000'
#   ./start_native_gpu_presto.sh -p ...
#   ./run_benchmark.sh -p ...

set -euo pipefail

KVIKIO_SRC_DIR=${KVIKIO_SRC_DIR:-${HOME}/rapids/kvikio}
CONTAINER_PLUGIN_DIR=${CONTAINER_PLUGIN_DIR:-/opt/nsys-plugins}
GCC_TOOLSET=${GCC_TOOLSET:-gcc-toolset-14}

while [[ $# -gt 0 ]]; do
  case $1 in
    --kvikio-src)
      KVIKIO_SRC_DIR=$2
      shift 2
      ;;
    -h|--help)
      sed -n '5,25p' "$0"
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

readonly PLUGIN_SRC_DIR="${KVIKIO_SRC_DIR}/cpp/nsys_plugins/nic"
if [[ ! -f ${PLUGIN_SRC_DIR}/kvikio_nic_nsys_plugin.cpp ]]; then
  echo "Error: no kvikio_nic plugin sources under ${PLUGIN_SRC_DIR}." >&2
  echo "       Point --kvikio-src at a KvikIO checkout that ships cpp/nsys_plugins/nic." >&2
  exit 1
fi

# One container per GPU when the cluster runs separate workers, otherwise a single one.
mapfile -t worker_containers < <(docker ps --format '{{.Names}}' --filter "name=^presto-native-worker-gpu")
if [[ ${#worker_containers[@]} -eq 0 ]]; then
  echo "Error: no running presto-native-worker-gpu container found. Start the cluster first." >&2
  exit 1
fi

readonly worker_image=$(docker inspect -f '{{.Config.Image}}' "${worker_containers[0]}")

build_dir=$(mktemp -d)
trap 'rm -rf "${build_dir}"' EXIT

echo "Building kvikio_nic plugin from ${PLUGIN_SRC_DIR} using ${worker_image}..."
docker run --rm \
  -v "${PLUGIN_SRC_DIR}:/kvikio_nic_src:ro" \
  -v "${build_dir}:/kvikio_nic_out" \
  -u "$(id -u):$(id -g)" \
  "${worker_image}" \
  bash -euo pipefail -c '
    source /opt/rh/'"${GCC_TOOLSET}"'/enable
    # nsys bundles the NVTX headers the plugin needs (counters, payloads, semantics).
    nvtx_include=$(echo /opt/nvidia/nsight-systems-cli/*/target-linux-x64/nvtx/include | cut -d" " -f1)
    g++ -std=c++20 -O2 -static-libstdc++ -static-libgcc \
      -I "${nvtx_include}" \
      /kvikio_nic_src/kvikio_nic_nsys_plugin.cpp /kvikio_nic_src/nic_monitor.cpp \
      -o /kvikio_nic_out/kvikio_nic_nsys_plugin \
      -lpthread -ldl
    cp /kvikio_nic_src/nsys-plugin.yaml /kvikio_nic_out/
  '

# nsys discovers a plugin by the directory that holds its executable and manifest, and
# NSYS_PLUGIN_SEARCH_DIRS names that directory's parent.
staged_dir="${build_dir}/kvikio_nic"
mkdir "${staged_dir}"
mv "${build_dir}/kvikio_nic_nsys_plugin" "${build_dir}/nsys-plugin.yaml" "${staged_dir}"

for container in "${worker_containers[@]}"; do
  docker exec "${container}" mkdir -p "${CONTAINER_PLUGIN_DIR}"
  docker exec "${container}" rm -rf "${CONTAINER_PLUGIN_DIR}/kvikio_nic"
  docker cp "${staged_dir}" "${container}:${CONTAINER_PLUGIN_DIR}/"
  if docker exec -e NSYS_PLUGIN_SEARCH_DIRS="${CONTAINER_PLUGIN_DIR}" "${container}" \
      nsys start --enable=help 2>/dev/null | grep -q kvikio_nic; then
    echo "Installed kvikio_nic into ${container}:${CONTAINER_PLUGIN_DIR}"
  else
    echo "Error: nsys in ${container} does not list kvikio_nic after install." >&2
    exit 1
  fi
done

cat <<EOF

Done. To put NIC bandwidth on the profile timeline, export these before run_benchmark.sh -p:

  export NSYS_PLUGIN_SEARCH_DIRS=${CONTAINER_PLUGIN_DIR}
  export PROFILE_NSYS_START_ARGS='--enable=kvikio_nic,-d,eth0,-i,20000'

The counters land in the "KvikIO NIC" NVTX domain, one rx/tx group per interface plus a
total. eth0 is the container's only non-loopback interface, so all S3 traffic flows through
it; drop the -d filter to monitor every interface instead.
EOF
