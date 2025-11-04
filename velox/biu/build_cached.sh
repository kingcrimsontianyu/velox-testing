#!/usr/bin/env bash

script_dir=../scripts

cd ${script_dir}

./build_centos_deps_image.sh
./setup_sccache_auth.sh
./build_velox.sh --sccache
