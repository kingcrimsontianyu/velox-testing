#!/usr/bin/env bash

# -x: Print each command before execution (trace mode)
# -e: Exit immediately on command failure (non-zero exit code)
# -u: Treat unset variables as errors instead of expanding to empty string
# -o pipefail: Return the exit code of the first failing command in a pipeline
set -xeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/../docker/docker-compose.adapters.build.yml"
CONTAINER_NAME="velox-adapters-build"

docker compose -f "$COMPOSE_FILE" run --rm \
  --cap-add=SYS_ADMIN \
  "$CONTAINER_NAME" \
  bash -c '
RCFILE=/tmp/.velox-bashrc
cat > "$RCFILE" << "RCEOF"
[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc
[ -f "$HOME/.bashrc" ] 2>/dev/null && . "$HOME/.bashrc"
export PS1="\[\033[01;32m\]\u@velox-container\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
export TERM="${TERM:-xterm-256color}"
alias ll="ls -alF --color=auto"
alias ls="ls --color=auto"
alias grep="grep --color=auto"
RCEOF
exec bash --rcfile "$RCFILE" -i
'