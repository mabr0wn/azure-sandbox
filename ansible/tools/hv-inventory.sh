#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_VARS_PATH="${HOST_VARS_PATH:-"$DIR/../host_vars"}"
PS_SCRIPT="${PS_SCRIPT:-"$DIR/../inventory/hyperv_inventory.ps1"}"
PWSH_BIN="${PWSH_BIN:-$(command -v pwsh)}"

exec "$PWSH_BIN" "$PS_SCRIPT" -HostVarsPath "$HOST_VARS_PATH" "$@"
