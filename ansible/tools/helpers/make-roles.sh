#!/usr/bin/env bash
set -euo pipefail

# Create roles and tasks directories
mkdir -p roles/{browsers,editors,devtools,common}/tasks

# Helper to write a stub only if the file doesn't exist
write_stub () {
  local file="$1"
  local title="$2"
  if [[ -f "$file" ]]; then
    echo "skip  $file (exists)"
  else
    cat >"$file" <<YAML
# ${title}
# Add tasks here. Example:
# - name: Example
#   ansible.builtin.debug:
#     msg: "Hello from ${title}"
YAML
    echo "create $file"
  fi
}

write_stub roles/browsers/tasks/main.yml "Browsers role (Brave, Chrome)"
write_stub roles/editors/tasks/main.yml  "Editors role (VS Code)"
write_stub roles/devtools/tasks/main.yml "Devtools role (Git, Python)"
write_stub roles/common/tasks/main.yml   "Common role (C:\\Temp, helpers)"

echo "✅ Roles scaffold ready."
