#!/usr/bin/env bash

export CUDA_VISIBLE_DEVICES=0

BUILD_TYPE=debug
VELOX_CUDF_TPCH_BENCHMARK=/opt/velox-build/${BUILD_TYPE}/velox/experimental/cudf/benchmarks/velox_cudf_tpch_benchmark
SCALE_FACTOR=0.01

# Local
# DATA_PATH=/mnt/nvme/velox-tpch-data/biu-partition/sf-${SCALE_FACTOR}

# AWS S3
DATA_PATH=/mnt/nvme/velox-tpch-data/biu-partition/sf-${SCALE_FACTOR}
# export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
# export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
# export AWS_DEFAULT_REGION=$(aws configure get region)
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export AWS_SESSION_TOKEN=
# export AWS_DEFAULT_REGION=us-east-2

export LIBCUDF_IO_REROUTE_LOCAL_DIR_PATTERN="/mnt/nvme/velox-tpch-data/biu-partition"
export LIBCUDF_IO_REROUTE_REMOTE_DIR_PATTERN="https://kvikio-remote-io-dev.s3.us-east-2.amazonaws.com/velox"

# Sparh-H: WebHDFS
# DATA_PATH=/mnt/nvme/velox-tpch-data/biu-partition/sf-${SCALE_FACTOR}
# export KVIKIO_WEBHDFS_USERNAME=hdfs
# export LIBCUDF_IO_REROUTE_LOCAL_DIR_PATTERN="/mnt/nvme/velox-tpch-data/biu-partition"
# export LIBCUDF_IO_REROUTE_REMOTE_DIR_PATTERN="http://sparkh-nn1.nvidia.com:9000/webhdfs/v1/data/velox-tpch/biu-partition"

OUTPUT_PATH=/mnt/nvme/velox-tpch-result/tmp.txt


gdb --ex start --args \
${VELOX_CUDF_TPCH_BENCHMARK} \
--data_path=${DATA_PATH} --data_format=parquet \
--run_query_verbose=05 --num_repeats=2 --num_drivers=4 --preferred_output_batch_rows=100000 \
--max_output_batch_rows=100000 \
--cudf_chunk_read_limit=1073741824 \
--cudf_pass_read_limit=0 2>&1 | tee ${OUTPUT_PATH}
