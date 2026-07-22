#!/usr/bin/env bash
# setup.sh — One-shot local setup for the demo application.
#
# - Loads JFrog env from ~/.zshrc
# - Verifies authentication
# - Installs npm dependencies (optionally via Artifactory when configured)
#
# Usage:
#   ./scripts/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT_DIR}"

echo "==> Loading environment"
# shellcheck source=load-env.sh
source "${SCRIPT_DIR}/load-env.sh"

echo ""
echo "==> Verifying JFrog Platform access"
"${SCRIPT_DIR}/verify-jfrog.sh"

echo ""
echo "==> Installing npm dependencies"
if command -v jf >/dev/null 2>&1; then
  # Prefer resolving through Artifactory when the CLI is configured
  if jf npmc show >/dev/null 2>&1 || true; then
    jf npm-config add --repo-resolve=demo-npm --server-id-resolve=mdk96-demo >/dev/null 2>&1 || true
  fi
fi

npm install

echo ""
echo "Setup complete."
echo "  Start the app:  npm start"
echo "  Health check:   curl http://localhost:3000/health"
echo "  App info:       curl http://localhost:3000/api/info"
