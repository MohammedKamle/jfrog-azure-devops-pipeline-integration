#!/usr/bin/env bash
# load-env.sh — Load JFrog credentials from ~/.zshrc into the current shell.
#
# Usage (from the project root):
#   source scripts/load-env.sh
#
# Expected variables in ~/.zshrc (already present on this machine):
#   export JFROG_URL="https://mdk96.jfrog.io"
#   export JFROG_TOKEN="<access-token>"
#
# This script also exports the JF_* aliases that JFrog CLI prefers.

set -euo pipefail

ZSHRC="${HOME}/.zshrc"

if [[ ! -f "${ZSHRC}" ]]; then
  echo "ERROR: ${ZSHRC} not found. Add JFROG_URL and JFROG_TOKEN there first." >&2
  return 1 2>/dev/null || exit 1
fi

# Extract exports without executing the entire .zshrc (avoids interactive prompts / p10k).
while IFS= read -r line; do
  # shellcheck disable=SC2163
  eval "${line}"
done < <(grep -E '^[[:space:]]*export[[:space:]]+(JFROG_URL|JFROG_TOKEN|JF_URL|JF_ACCESS_TOKEN)=' "${ZSHRC}" || true)

# Normalize aliases used by JFrog CLI and helper scripts
if [[ -n "${JFROG_URL:-}" ]]; then
  export JFROG_URL="${JFROG_URL%/}"
  export JF_URL="${JFROG_URL}"
fi

if [[ -n "${JFROG_TOKEN:-}" ]]; then
  export JF_ACCESS_TOKEN="${JFROG_TOKEN}"
fi

# Allow JF_* already set in .zshrc to win if JFROG_* were missing
if [[ -z "${JFROG_URL:-}" && -n "${JF_URL:-}" ]]; then
  export JFROG_URL="${JF_URL%/}"
fi
if [[ -z "${JFROG_TOKEN:-}" && -n "${JF_ACCESS_TOKEN:-}" ]]; then
  export JFROG_TOKEN="${JF_ACCESS_TOKEN}"
fi

missing=0
if [[ -z "${JFROG_URL:-}" ]]; then
  echo "ERROR: JFROG_URL is not set in ${ZSHRC}" >&2
  missing=1
fi
if [[ -z "${JFROG_TOKEN:-}" ]]; then
  echo "ERROR: JFROG_TOKEN is not set in ${ZSHRC}" >&2
  missing=1
fi

if [[ "${missing}" -ne 0 ]]; then
  return 1 2>/dev/null || exit 1
fi

# Masked confirmation (never print the raw token)
token_len="${#JFROG_TOKEN}"
echo "Loaded JFrog environment from ${ZSHRC}"
echo "  JFROG_URL / JF_URL          = ${JFROG_URL}"
echo "  JFROG_TOKEN / JF_ACCESS_TOKEN = *** (${token_len} chars)"
