#!/usr/bin/env bash

set -euo pipefail

source "../scripts/config.sh"

docker compose -f "$COMPOSE_FILE" run --rm "${CONTAINER_NAME}" bash -c '
# Source conda if available
if [ -f "/opt/miniforge/etc/profile.d/conda.sh" ]; then
    source "/opt/miniforge/etc/profile.d/conda.sh"
    conda activate adapters
fi

# Setup HDFS classpath
export CLASSPATH=$(/usr/local/hadoop/bin/hdfs classpath --glob)

# Set a user-friendly prompt showing current directory
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

# Start interactive bash
exec bash
'