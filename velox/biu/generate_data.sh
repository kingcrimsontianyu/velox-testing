#!/usr/bin/env bash

python3 -m venv biu-venv-velox
source biu-venv-velox/bin/activate

scale_factor=0.01
max_rows_per_file=200000

# scale_factor=1
# max_rows_per_file=200000

data_script_dir=../../benchmark_data_tools
data_dest_dir=/mnt/nvme_ubuntu_test/velox-tpch-data/biu-partition/sf-${scale_factor}


pip install -r ${data_script_dir}/requirements.txt
python ${data_script_dir}/generate_data_files.py \
-b tpch -d $data_dest_dir -s ${scale_factor} -c \
--max-rows-per-file ${max_rows_per_file}
