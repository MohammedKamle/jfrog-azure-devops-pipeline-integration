#!/usr/bin/env bash
# verify-jfrog.sh — Confirm JFrog Platform authentication before Azure DevOps setup.
#
# Prerequisites:
#   - JFrog CLI (`jf`) installed: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/install
#   - JFROG_URL and JFROG_TOKEN present in ~/.zshrc
#
# Usage:
#   ./scripts/verify-jfrog.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=load-env.sh
source "${SCRIPT_DIR}/load-env.sh"

if ! command -v jf >/dev/null 2>&1; then
  echo "ERROR: JFrog CLI (jf) is not installed or not on PATH." >&2
  echo "Install: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/install" >&2
  exit 1
fi

echo ""
echo "==> JFrog CLI version"
jf --version

SERVER_ID="mdk96-demo"

echo ""
echo "==> Configuring temporary CLI server '${SERVER_ID}'"
jf config add "${SERVER_ID}" \
  --url="${JF_URL}" \
  --access-token="${JF_ACCESS_TOKEN}" \
  --interactive=false \
  --overwrite=true

echo ""
echo "==> Pinging Artifactory (REST)"
HTTP_CODE="$(curl -sS -o /tmp/jfrog-ping-body.txt -w '%{http_code}' \
  -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" \
  "${JF_URL}/artifactory/api/system/ping")"
BODY="$(cat /tmp/jfrog-ping-body.txt)"
rm -f /tmp/jfrog-ping-body.txt

if [[ "${HTTP_CODE}" != "200" || "${BODY}" != "OK" ]]; then
  echo "ERROR: Artifactory ping failed (HTTP ${HTTP_CODE}, body: ${BODY})" >&2
  exit 1
fi
echo "Artifactory ping: OK (https://mdk96.jfrog.io/)"

echo ""
echo "==> Verifying npm virtual repository 'demo-npm'"
REPO_JSON="$(curl -sS -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" \
  "${JF_URL}/artifactory/api/repositories/demo-npm")"
REPO_KEY="$(echo "${REPO_JSON}" | jq -r '.key // empty')"
REPO_CLASS="$(echo "${REPO_JSON}" | jq -r '.rclass // empty')"
PKG_TYPE="$(echo "${REPO_JSON}" | jq -r '.packageType // empty')"

if [[ "${REPO_KEY}" != "demo-npm" ]]; then
  echo "ERROR: demo-npm not found or not accessible." >&2
  echo "${REPO_JSON}" | jq . >&2 || echo "${REPO_JSON}" >&2
  exit 1
fi

echo "  key         = ${REPO_KEY}"
echo "  class       = ${REPO_CLASS}"
echo "  packageType = ${PKG_TYPE}"

echo ""
echo "==> Checking CLI download proxy 'jfrog-cli-remote' (used by Azure pipeline)"
CLI_HTTP="$(curl -sS -o /tmp/jfrog-cli-repo.json -w '%{http_code}' \
  -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" \
  "${JF_URL}/artifactory/api/repositories/jfrog-cli-remote")"
if [[ "${CLI_HTTP}" == "200" ]]; then
  jq '{key,rclass,packageType,url}' /tmp/jfrog-cli-repo.json
else
  echo "WARNING: jfrog-cli-remote returned HTTP ${CLI_HTTP}."
  echo "Create a generic remote repo named jfrog-cli-remote pointing to:"
  echo "  https://releases.jfrog.io/artifactory/jfrog-cli/v2-jf/"
fi
rm -f /tmp/jfrog-cli-repo.json

echo ""
echo "SUCCESS: JFrog authentication is working."
echo "Next steps:"
echo "  1. Push this project to GitHub"
echo "  2. Connect the repo to Azure DevOps and install the JFrog extension"
echo "  3. Create Platform + Xray service connections using the same token"
echo "  4. Run the pipeline defined in azure-pipelines.yml"
