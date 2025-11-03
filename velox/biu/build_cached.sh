#!/usr/bin/env bash

script_dir=../scripts

cd ${script_dir}

./setup_sccache_auth.sh
./build_velox.sh --sccache
