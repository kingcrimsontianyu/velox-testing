#!/usr/bin/env bash

export CUDA_VISIBLE_DEVICES=0

# build_type=debug
build_type=release
velox_cudf_tpch_benchmark=/opt/velox-build/${build_type}/velox/experimental/cudf/benchmarks/velox_cudf_tpch_benchmark
scale_factor=10

# data_dir=s3://biu-velox/velox-tpch-data/sf-${scale_factor}
# data_dir=https://biu-velox.s3.us-east-1.amazonaws.com/velox-tpch-data/sf-${scale_factor}
data_dir=/mnt/nvme/velox-tpch-data/sf-${scale_factor}

output_path=/mnt/nvme/velox-tpch-result/tmp.txt


# AWS S3
# export AWS_CONFIG_FILE="/mnt/host_home/.aws/config"
# export AWS_SHARED_CREDENTIALS_FILE="/mnt/host_home/.aws/credentials"
# data_dir=/mnt/nvme/velox-tpch-data/biu-partition/sf-${scale_factor}
# export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
# export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
# export AWS_DEFAULT_REGION=$(aws configure get region)
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export AWS_SESSION_TOKEN=
# export AWS_DEFAULT_REGION=us-east-2

# export LIBCUDF_IO_REROUTE_LOCAL_DIR_PATTERN="/mnt/nvme/velox-tpch-data/biu-partition"
# export LIBCUDF_IO_REROUTE_REMOTE_DIR_PATTERN="https://kvikio-remote-io-dev.s3.us-east-2.amazonaws.com/velox"

# Sparh-H: WebHDFS
# data_dir=/mnt/nvme/velox-tpch-data/biu-partition/sf-${scale_factor}
# export KVIKIO_WEBHDFS_USERNAME=hdfs
# export LIBCUDF_IO_REROUTE_LOCAL_DIR_PATTERN="/mnt/nvme/velox-tpch-data/biu-partition"
# export LIBCUDF_IO_REROUTE_REMOTE_DIR_PATTERN="http://sparkh-nn1.nvidia.com:9000/webhdfs/v1/data/velox-tpch/biu-partition"


${velox_cudf_tpch_benchmark} \
--data_path=${data_dir} \
--data_format=parquet \
--run_query_verbose=05 \
--num_repeats=2 \
--num_drivers=4 \
--cudf_chunk_read_limit=1073741824 \
--cudf_pass_read_limit=0 \
--cudf_memory_resource=async 2>&1 | tee ${output_path}


# gdb --ex start --args \
# ${velox_cudf_tpch_benchmark} \
# --data_dir=${data_dir} --data_format=parquet \
# --run_query_verbose=05 --num_repeats=2 --num_drivers=4 --preferred_output_batch_rows=100000 \
# --max_output_batch_rows=100000 \
# --cudf_chunk_read_limit=1073741824 \
# --cudf_pass_read_limit=0 2>&1 | tee ${output_path}
