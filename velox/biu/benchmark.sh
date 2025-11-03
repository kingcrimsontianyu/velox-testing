#!/usr/bin/env bash

data_dir=$(pwd)/tpch-data

cd ../scripts
./benchmark_velox.sh --queries 5 --device-type gpu --data-dir ${data_dir}

