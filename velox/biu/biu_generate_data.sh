#!/usr/bin/env bash

# python3 -m venv biu-venv-velox
source biu-venv-velox/bin/activate

cd ../../benchmark_data_tools
# pip install -r requirements.txt
python generate_data_files.py -b tpch -d ~/biubiu/rapids/velox-testing/biu-test-data -s 1
