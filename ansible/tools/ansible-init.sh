#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Ansible repo bootstrap (for layout with ansible/tools/*)
# Creates group_vars, host_vars, inventories, vault, and cfg.
#
# Usage:
#   ./ansible/tools/ansible-init.sh [--vault-pass <path>] [--host <alias>=<ip>]...
#
# Examples:
#   ./ansible/tools/ansible-init.sh --vault-pass .vault-pass.txt \
#       --host SKYNETDC01=172.16.3.105 --host Skynet-Veeam=172.16.3.110
#   ./ansible/tools/ansible-init.sh --host web1=10.0.0.10
# ------------------------------------------------------------

# --- Path resolution (script must be inside ansible/tools) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"           # .../ansible
REPO_ROOT="$(cd "$ANS_DIR/.." && pwd)"            # repo root

INV_DIR="$ANS_DIR/inventory"
GV_DIR="$ANS_DIR/group_vars"
HV_DIR="$ANS_DIR/host_vars"
TOOLS_DIR="$ANS_DIR/tools"
ANS_CFG="$ANS_DIR/ansible.cfg"

# Default vault-pass lives at repo root (can override with --vault-pass)
VAULT_PASS_FILE="$REPO_ROOT/.vault-pass.txt"

WIN_GV="$GV_DIR/windows.yml"
LIN_GV="$GV_DIR/linux.yml"
VAULT_GV="$GV_DIR/vault.yml"

AZ_INV="$INV_DIR/azure_rm.yml"
HV_INV="$INV_DIR/hyperv_inventory.ps1"
STATIC_INV="$INV_DIR/static_hosts.yml"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [--vault-pass <path>] [--host <alias>=<ip>]...

Examples:
  $(basename "$0") --vault-pass .vault-pass.txt --host SKYNETDC01=172.16.3.105 --host Skynet-Veeam=172.16.3.110
  $(basename "$0") --host web1=10.0.0.10

Notes:
- If the vault password file is missing, a placeholder will be created.
- Hosts provided with --host create vaulted files at host_vars/<alias>/vault.yml with ansible_host set.
EOF
}

VAULT_PASS_ARG=""
HOSTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault-pass) VAULT_PASS_ARG="$2"; shift 2;;
    --host) HOSTS+=("$2"); shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

# --- Ensure directories exist ---
mkdir -p "$ANS_DIR" "$INV_DIR" "$GV_DIR" "$HV_DIR" "$TOOLS_DIR"

# --- .gitignore entry for vault pass (at repo root) ---
if ! grep -q "^$(basename "$VAULT_PASS_FILE")\$" "$REPO_ROOT/.gitignore" 2>/dev/null; then
  echo "$(basename "$VAULT_PASS_FILE")" >> "$REPO_ROOT/.gitignore"
fi

# --- Vault password file ---
if [[ -n "$VAULT_PASS_ARG" ]]; then
  # If user passed a relative path, treat it as relative to repo root for convenience
  case "$VAULT_PASS_ARG" in
    /*) VAULT_PASS_FILE="$VAULT_PASS_ARG" ;;
    *)  VAULT_PASS_FILE="$REPO_ROOT/$VAULT_PASS_ARG" ;;
  esac
fi

if [[ ! -f "$VAULT_PASS_FILE" ]]; then
  echo "CHANGE_ME" > "$VAULT_PASS_FILE"
  chmod 600 "$VAULT_PASS_FILE" || true
  echo "Created $(realpath "$VAULT_PASS_FILE") (placeholder)."
fi

# --- Preflight: ansible-vault available ---
if ! command -v ansible-vault >/dev/null 2>&1; then
  echo "ERROR: ansible-vault not found in PATH. Install Ansible first." >&2
  exit 1
fi

# --- ansible.cfg (inside ansible/) ---
if [[ ! -f "$ANS_CFG" ]]; then
  cat >"$ANS_CFG" <<'INI'
[defaults]
inventory = ./inventory
roles_path = ./roles
host_key_checking = False
retry_files_enabled = False
timeout = 30
forks = 20

# Pick up group_vars/host_vars automatically
hash_behaviour = merge

[privilege_escalation]
# Linux sudo defaults; Windows uses runas only when needed in tasks
become = True
become_method = sudo
become_user = root
INI
  echo "Wrote $ANS_CFG"
fi

# --- group_vars/windows.yml ---
if [[ ! -f "$WIN_GV" ]]; then
  cat >"$WIN_GV" <<'YAML'
ansible_connection: winrm
ansible_winrm_transport: basic
ansible_winrm_server_cert_validation: ignore

ansible_user: Administrator
ansible_password: "{{ vault_windows_admin_password }}"

ansible_become: yes
ansible_become_method: runas
ansible_become_user: Administrator
YAML
  echo "Wrote $WIN_GV"
fi

# --- group_vars/linux.yml ---
if [[ ! -f "$LIN_GV" ]]; then
  cat >"$LIN_GV" <<'YAML'
ansible_connection: ssh
ansible_user: azureuser
ansible_ssh_private_key_file: ~/.ssh/id_rsa
ansible_ssh_pass: "{{ vault_linux_privkey_passphrase | default(omit) }}"

ansible_become: yes
ansible_become_method: sudo
ansible_become_user: root
YAML
  echo "Wrote $LIN_GV"
fi

# --- group_vars/vault.yml (encrypted) ---
if [[ ! -f "$VAULT_GV" ]]; then
  tmpfile="$(mktemp)"
  cat >"$tmpfile" <<'YAML'
# Edit with:
#   ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt ansible-vault edit ansible/group_vars/vault.yml
vault_windows_admin_password: "CHANGE_ME_WINDOWS_ADMIN"
vault_linux_privkey_passphrase: ""
YAML
  ansible-vault encrypt --vault-password-file "$VAULT_PASS_FILE" "$tmpfile" --output "$VAULT_GV" >/dev/null
  rm -f "$tmpfile"
  echo "Created encrypted $VAULT_GV"
fi

# --- inventory: azure_rm.yml ---
if [[ ! -f "$AZ_INV" ]]; then
  cat >"$AZ_INV" <<'YAML'
plugin: azure_rm
auth_source: auto
include_powerstate: yes
plain_host_names: yes
keyed_groups:
  - key: os_profile.windows_configuration
    prefix: windows
    value: present
  - key: os_profile.linux_configuration
    prefix: linux
    value: present
YAML
  echo "Wrote $AZ_INV"
fi

# --- inventory: hyperv_inventory.ps1 (minimal safe stub) ---
if [[ ! -f "$HV_INV" ]]; then
  cat >"$HV_INV" <<'POWERSHELL'
#!/usr/bin/env pwsh
# Hyper-V Dynamic Inventory (aliases only; host details resolved via host_vars)
$inventory = @{
  all = @{
    children = @{
      windows = @{ hosts = @{} }
      linux   = @{ hosts = @{} }
    }
  }
}
$inventory | ConvertTo-Json -Depth 10
POWERSHELL
  chmod +x "$HV_INV" || true
  echo "Wrote $HV_INV"
fi

# --- inventory: static_hosts.yml (example skeleton) ---
if [[ ! -f "$STATIC_INV" ]]; then
  cat >"$STATIC_INV" <<'YAML'
all:
  children:
    windows:
      hosts: {}
    linux:
      hosts: {}
# Put real hosts in host_vars/<HOST>/vault.yml as:
#   ansible_host: "IP.ADDR.ESS"
YAML
  echo "Wrote $STATIC_INV"
fi

# --- host_vars for provided --host alias=ip pairs (encrypted) ---
if [[ ${#HOSTS[@]} -gt 0 ]]; then
  for pair in "${HOSTS[@]}"; do
    alias="${pair%%=*}"
    ip="${pair#*=}"
    if [[ -z "$alias" || -z "$ip" || "$alias" == "$ip" ]]; then
      echo "Skipping malformed --host '$pair' (use alias=ip)"; continue
    fi
    d="$HV_DIR/$alias"
    f="$d/vault.yml"
    mkdir -p "$d"
    if [[ -f "$f" ]]; then
      echo "Host vars already exist: $f (skipping)"
    else
      tmp="$(mktemp)"
      printf "ansible_host: \"%s\"\n" "$ip" > "$tmp"
      ansible-vault encrypt --vault-password-file "$VAULT_PASS_FILE" "$tmp" --output "$f" >/dev/null
      rm -f "$tmp"
      echo "Added vaulted host_vars for $alias ($ip): $f"
    fi
  done
fi

echo
echo "✅ Bootstrap complete."
echo "Repo root:    $REPO_ROOT"
echo "Ansible dir:  $ANS_DIR"
echo
echo "Next steps:"
echo "  1) Edit vault:"
echo "     ANSIBLE_VAULT_PASSWORD_FILE=$(realpath --relative-to=\"$REPO_ROOT\" \"$VAULT_PASS_FILE\" 2>/dev/null || echo \"$VAULT_PASS_FILE\") \\"
echo "        ansible-vault edit $(realpath --relative-to=\"$REPO_ROOT\" \"$VAULT_GV\" 2>/dev/null || echo \"$VAULT_GV\")"
echo "  2) From repo root, either:"
echo "     - export ANSIBLE_CONFIG=ansible/ansible.cfg"
echo "       or run inside the ansible/ directory so ansible.cfg is auto-detected."
echo "  3) Visualize inventory:"
echo "     ansible-inventory -i ansible/inventory --graph"
