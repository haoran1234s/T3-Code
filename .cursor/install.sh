#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for T3 Code.
#
# Prepares the two toolchain pieces the repo needs on top of Cursor's default
# image and then installs workspace dependencies:
#   1. Node 24 (package.json pins engines.node ^24.13.1).
#   2. Vite+ (`vp`), the repo's package manager and task runner.
#
# Safe to run repeatedly: every step no-ops when its result already exists.
set -euo pipefail

NODE_VERSION="24.13.1"

export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION" >/dev/null
nvm use "$NODE_VERSION" >/dev/null

# The default image keeps an older Node ahead of nvm on PATH in non-login
# shells, so pin the Node 24 bin dir explicitly for the rest of this script and
# for `vp`.
export PATH="$HOME/.nvm/versions/node/v${NODE_VERSION}/bin:$PATH"

if [ ! -x "$HOME/.vite-plus/bin/vp" ]; then
  curl -fsSL https://vite.plus | bash
fi
export PATH="$HOME/.vite-plus/bin:$PATH"

echo "node: $(node -v)"
echo "vp: $(vp --version | head -1)"

# Installs the pnpm workspace, compiles node-pty, and runs the repo's prepare
# step (Effect language-service patch + `vp config`).
vp i
