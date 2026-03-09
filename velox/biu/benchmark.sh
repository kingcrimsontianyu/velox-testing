#!/usr/bin/env bash

# scale_factor=10
# data_dir=/mnt/nvme_ubuntu_test/velox-tpch-data/sf-${scale_factor}
# output_dir=/mnt/nvme_ubuntu_test/velox-tpch-result/tmp

scale_factor=1000
# umb-b200-220 TPC-H data location:
data_dir=/raid/datasets/ocs_benchmark_data/tpch/sf1k_64mb
output_dir=/raid/tialiu/rapids/velox-tpch-result/tmp

export CUDA_VISIBLE_DEVICES=7

cd ../scripts
# ./benchmark_velox.sh  --device-type gpu --data-dir ${data_dir} --output ${output_dir}
./benchmark_velox.sh --queries 5 --device-type gpu --data-dir ${data_dir} --output ${output_dir}
