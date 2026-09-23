#!/usr/bin/env bash
set -uo pipefail

cd ..

export AWS_DEFAULT_REGION=us-east-2

export KVIKIO_TASK_SIZE=$((64 * 1024 * 1024))
export KVIKIO_BOUNCE_BUFFER_SIZE=$((64 * 1024 * 1024))
# export KVIKIO_REMOTE_IO_BACKEND=EASY_THREADPOOL
export KVIKIO_REMOTE_IO_BACKEND=MULTI_POLL
export KVIKIO_REMOTE_IO_NUM_REACTORS=24
export KVIKIO_REMOTE_IO_MAX_CONCURRENT_REQUESTS=384
export LIBCUDF_NUM_HOST_WORKERS=48
export KVIKIO_REMOTE_IO_REACTOR_DISPATCH=SHARED_QUEUE
export KVIKIO_LOG_LEVEL=INFO

# Puts a NIC bandwidth timeline in the nsys report via KvikIO's kvikio_nic plugin. Only has an
# effect when profiling is on, and needs biu/install_kvikio_nsys_plugin.sh to have been run
# against the current worker container.
export NSYS_PLUGIN_SEARCH_DIRS=/opt/nsys-plugins
export PROFILE_NSYS_START_ARGS='--enable=kvikio_nic,-d,eth0,-i,20000'

./start_native_gpu_presto.sh --overwrite-config --kvikio-threads 384 --num-drivers 4 \
--logs-dir /opt/dlami/nvme/presto_logs
# -p --profile-args "-t nvtx,cuda --cuda-memory-usage=true"
#-b worker
# ./biu/install_kvikio_nsys_plugin.sh   # after the worker is up, when profiling with -p

# Reference data location: s3://rapids-tpch/presto-gpu/sf1k_v2_float/expected/
./run_benchmark.sh -b tpch -s tpch_sf1k_v2_float_s3 --reference-results-dir ~/rapids/reference_data/sf1k_v2_float -i 3 -q 18
# --cache-mode cold-once
# -i 2 -q 1
#-p

cd -
