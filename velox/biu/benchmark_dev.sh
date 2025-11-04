#!/usr/bin/env bash

VELOX_CUDF_TPCH_BENCHMARK=/opt/velox-build/release/velox/experimental/cudf/benchmarks/velox_cudf_tpch_benchmark
SCALE_FACTOR=0.01
DATA_PATH=/mnt/nvme/velox-tpch-data/sf-${SCALE_FACTOR}
OUTPUT_PATH=/mnt/nvme/velox-tpch-result/tmp.txt

${VELOX_CUDF_TPCH_BENCHMARK} \
--data_path=${DATA_PATH} --data_format=parquet \
--run_query_verbose=05 --num_repeats=2 --num_drivers=4 --preferred_output_batch_rows=100000 \
--max_output_batch_rows=100000 \
--cudf_chunk_read_limit=1073741824 \
--cudf_pass_read_limit=0 2>&1 | tee ${OUTPUT_PATH}
