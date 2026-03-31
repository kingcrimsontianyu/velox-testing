#!/usr/bin/env bash

# Install Python env
# python3 -m venv /raid/tialiu/python_venv
# source /raid/tialiu/python_venv/bin/activate
# pip install -r ../../benchmark_reporting_tools/requirements.txt

# Add storage option if not available in the database
# Ref: https://accel-etl.nvidia.com/api/docs
# export TOKEN=xxx
# payload=$(jq -n \
#   --arg name "umb-raid-sf1k-v2-float" \
#   --slurpfile table_metadata /path/to/dataset-root/metadata.json \
#   '{
#         storage_configuration_name: $name,
#         storage_system: "nvme",
#         file_format: "parquet",
#         compression: "snappy",
#         region: "n/a",
#         is_gds_enabled: false,
#         table_metadata: $table_metadata[0]
#     }')
# curl -X POST -H "Content-Type: application/json" \
#     -H "Authorization: Bearer $TOKEN" \
#     https://accel-etl.nvidia.com/api/storage-configs/ \
#     -d "$payload"

cd ../..
python3 benchmark_reporting_tools/post_results.py presto/scripts/benchmark_output \
    --sku-name umb-220-GB200 \
    --storage-configuration-name umb-raid-sf1k-v2-float \
    --benchmark-name tpch-rs-1000 \
    --identifier-hash "" \
    --cache-state warm \
    --api-url="https://accel-etl.nvidia.com" \
    --api-key=b5c3bf5994f655bbdd36ba84b431bd5333120e60

