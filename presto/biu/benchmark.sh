#!/usr/bin/env bash

# -x: Print each command before execution (trace mode)
# -e: Exit immediately on command failure (non-zero exit code)
# -u: Treat unset variables as errors instead of expanding to empty string
# -o pipefail: Return the exit code of the first failing command in a pipeline
set -xeuo pipefail

cd ../scripts

export PRESTO_DATA_DIR=/raid/knataraj/datasets

# ./start_native_gpu_presto.sh
# ./run_integ_test.sh -b tpch

# # TPC-H SQL
# ./run_benchmark.sh -b tpch -s sf10k_v2_float -f 10000 --queries-file /raid/knataraj/velox-testing/presto/testing/common/queries/tpch/queries.json
# # Devevaret's SQL (Q17, Q21 optimized)
# ./run_benchmark.sh -b tpch -s sf1k_v2_float -f 1000

./run_benchmark.sh -b tpch -s sf1k_v2_float -f 1000 -q 1

