#!/usr/bin/env bash

# -x: Print each command before execution (trace mode)
# -e: Exit immediately on command failure (non-zero exit code)
# -u: Treat unset variables as errors instead of expanding to empty string
# -o pipefail: Return the exit code of the first failing command in a pipeline
set -xeuo pipefail

cd ../scripts
export PRESTO_DATA_DIR=/raid/knataraj/datasets
# ./start_native_gpu_presto.sh #--no-cache --build worker
./start_native_gpu_presto.sh -w 4 -g 0,1,2,3

# ./setup_benchmark_data_and_tables.sh -b tpch -s sf1k_v2_float -d sf1k_v2_float -f 1000 -c
