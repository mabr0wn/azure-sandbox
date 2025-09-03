#!/usr/bin/env bash
set -euo pipefail

: "${REGION:?set REGION}"

az vm list-skus \
  --location "$REGION" \
  --all \
  --query "[?length(restrictions)>`0`].{name:name,restr:restrictions}" \
  -o table
