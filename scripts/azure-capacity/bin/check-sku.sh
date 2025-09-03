#!/usr/bin/env bash
# Simple check if a SKU is restricted in a region
set -euo pipefail

: "${SKU:?Need to set SKU (e.g., Standard_D4s_v5)}"
: "${REGION:?Need to set REGION (e.g., eastus)}"

az vm list-skus \
  --location "$REGION" \
  --size "$SKU" \
  --all \
  --query "[].{name:name,cap:capabilities,restrictions:restrictions}" \
  -o json
