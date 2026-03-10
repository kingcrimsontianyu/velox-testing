#!/usr/bin/env bash

# -x: Print each command before execution (trace mode)
# -e: Exit immediately on command failure (non-zero exit code)
# -u: Treat unset variables as errors instead of expanding to empty string
# -o pipefail: Return the exit code of the first failing command in a pipeline
set -xeuo pipefail

export PRESTO_DATA_DIR=/raid/knataraj/datasets
velox_testing_dir_host=$(pwd)/../..
velox_testing_dir_container=/velox_testing

# Create a temp rcfile on the host
RCFILE=$(mktemp)
cat > "${RCFILE}" <<'EOF'
eval "$(dircolors -b)"
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias dir="dir --color=auto"
EOF

docker run --rm -it \
  --gpus all \
  --hostname "${USER}-presto-velox" \
  -e "PS1=\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ " \
  -e "TERM=xterm-256color" \
  -v "${RCFILE}":/tmp/.bashrc:ro \
  -v ${PRESTO_DATA_DIR}:/var/lib/presto/data/hive/data/user_data \
  -v "${velox_testing_dir_host}":"${velox_testing_dir_container}" \
  -w "${velox_testing_dir_container}" \
  presto-native-worker-gpu \
  bash --rcfile /tmp/.bashrc

rm -f "${RCFILE}"
