#!/usr/bin/env bash

python3 -m venv biu-venv-velox
source biu-venv-velox/bin/activate

data_script_dir=../../benchmark_data_tools

pip install -r ${data_script_dir}/requirements.txt
python ${data_script_dir}/generate_data_files.py -b tpch -d tpch-data -s 1 -c
