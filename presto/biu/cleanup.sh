#!/usr/bin/env bash

# -x: Print each command before execution (trace mode)
# -e: Exit immediately on command failure (non-zero exit code)
# -u: Treat unset variables as errors instead of expanding to empty string
# -o pipefail: Return the exit code of the first failing command in a pipeline
set -xeuo pipefail

docker container rm -f presto-native-worker-gpu presto-coordinator
