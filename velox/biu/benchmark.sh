#!/usr/bin/env bash

scale_factor=0.01
data_dir=/mnt/nvme_ubuntu_test/velox-tpch-data/sf-${scale_factor}
output_dir=/mnt/nvme_ubuntu_test/velox-tpch-result/tmp

cd ../scripts
./benchmark_velox.sh --queries 5 --device-type gpu --data-dir ${data_dir} --output ${output_dir}

