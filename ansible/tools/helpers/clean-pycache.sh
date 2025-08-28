#!/usr/bin/env bash
set -euo pipefail

echo "== Cleaning up __pycache__ folders =="

# Remove all __pycache__ dirs under ansible/tests
find ansible/tests -type d -name "__pycache__" -exec rm -rf {} +

echo "== Done =="
tree ansible/tests || ls -R ansible/tests
