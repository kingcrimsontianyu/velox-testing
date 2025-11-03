#!/usr/bin/env bash

set -euo pipefail

source "config.sh"

docker compose -f "$COMPOSE_FILE" run --rm "${CONTAINER_NAME}" bash -c '
# Source conda if available
if [ -f "/opt/miniforge/etc/profile.d/conda.sh" ]; then
    source "/opt/miniforge/etc/profile.d/conda.sh"
    conda activate adapters
fi

# Setup HDFS classpath
export CLASSPATH=$(/usr/local/hadoop/bin/hdfs classpath --glob)

# Start interactive bash
exec bash
'