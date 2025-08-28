#!/usr/bin/env bash
set -euo pipefail

# --- Config: adjust these two if your paths differ ---
BICEP_TEMPLATES_DIR="IaC/bicep/templates"
TERRAFORM_ROOT_DIR="IaC/terraform"

# --- Files to create inside each Terraform module (empty by request) ---
TF_FILES=(
  "main.tf"
  "variables.tf"
  "outputs.tf"
  "providers.tf"
  "versions.tf"
  "README.md"
)

# Resolve repo root (fallback to cwd)
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SRC_DIR="${REPO_ROOT}/${BICEP_TEMPLATES_DIR}"
DST_DIR="${REPO_ROOT}/${TERRAFORM_ROOT_DIR}"

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "✖ Source directory not found: ${SRC_DIR}"
  exit 1
fi

echo "➤ Scaffolding Terraform modules from: ${SRC_DIR}"
echo "  → Destination root: ${DST_DIR}"
mkdir -p "${DST_DIR}"

# Find only immediate child directories (modules) in templates/
while IFS= read -r -d '' module_dir; do
  module_name="$(basename "${module_dir}")"
  tf_module_path="${DST_DIR}/${module_name}"

  # Skip non-module directories you don’t want to mirror
  case "${module_name}" in
    # add exclusions here if needed, e.g. "create-deployment-script") continue ;;
    *) ;;
  esac

  mkdir -p "${tf_module_path}"

  # Create empty files if they don’t exist
  for f in "${TF_FILES[@]}"; do
    touch "${tf_module_path}/${f}"
  done

  echo "  ✓ ${module_name}  →  ${tf_module_path}"

done < <(find "${SRC_DIR}" -mindepth 1 -maxdepth 1 -type d -print0)

echo "✅ Done. Modules created under: ${DST_DIR}"
