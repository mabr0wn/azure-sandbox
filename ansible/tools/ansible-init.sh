#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Ansible repo bootstrap (for layout with ansible/tools/*)
# Creates group_vars, host_vars, inventories, vault, and cfg.
#
# Usage:
#   ./ansible/tools/ansible-init.sh [--vault-pass <path>] [--host <alias>=<ip>]...
#
# Example:
#   ./ansible/tools/ansible-init.sh --host skynet-ca=172.16.3.154 --host skyn3t=172.16.3.157
# ------------------------------------------------------------

# --- Path resolution (script must be inside ansible/tools) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"           # .../ansible
REPO_ROOT="$(cd "$ANS_DIR/.." && pwd)"            # repo root

INV_DIR="$ANS_DIR/inventory"
GV_DIR="$ANS_DIR/group_vars"
GV_ALL_DIR="$GV_DIR/all"
HV_DIR="$ANS_DIR/host_vars"
TOOLS_DIR="$ANS_DIR/tools"
ANS_CFG="$ANS_DIR/ansible.cfg"

# Default vault-pass (can override with --vault-pass)
VAULT_PASS_FILE="$REPO_ROOT/.vault-pass.txt"

WIN_GV="$GV_DIR/windows.yml"
LIN_GV="$GV_DIR/linux.yml"
VAULT_GV="$GV_ALL_DIR/vault.yml"

AZ_INV="$INV_DIR/azure_rm.yml"
HV_INV="$INV_DIR/hyperv_inventory.ps1"
STATIC_INV="$INV_DIR/static_hosts.yml"
PING_INV="$INV_DIR/ping_hosts.ini"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [--vault-pass <path>] [--host <alias>=<ip>]...

Notes:
- Vault lives at group_vars/all/vault.yml (encrypted)
- Each --host:
    * creates host_vars/<alias>/main.yml with ansible_host mapping
    * appends <alias> to inventory/ping_hosts.ini [windows] (no dupes)
    * updates ansible_host_map in the encrypted vault
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
mkdir -p "$ANS_DIR" "$INV_DIR" "$GV_DIR" "$GV_ALL_DIR" "$HV_DIR" "$TOOLS_DIR"

# --- .gitignore entry for vault pass (at repo root) ---
if ! grep -q "^$(basename "$VAULT_PASS_FILE")\$" "$REPO_ROOT/.gitignore" 2>/dev/null; then
  echo "$(basename "$VAULT_PASS_FILE")" >> "$REPO_ROOT/.gitignore"
fi

# --- Vault password file ---
if [[ -n "$VAULT_PASS_ARG" ]]; then
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
hash_behaviour = merge

[privilege_escalation]
become = True
become_method = sudo
become_user = root
INI
  echo "Wrote $ANS_CFG"
fi

# --- group_vars/windows.yml (domain-joined defaults via NTLM) ---
if [[ ! -f "$WIN_GV" ]]; then
  cat >"$WIN_GV" <<'YAML'
ansible_connection: winrm
ansible_port: 5985
ansible_winrm_scheme: http
ansible_winrm_transport: ntlm
ansible_winrm_server_cert_validation: ignore
ansible_become: false

# Domain account used for all Windows members by default
ansible_user: "SKYNET\\{{ vault_domain_admin_user }}"
ansible_password: "{{ vault_domain_admin_password }}"
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

# --- group_vars/all/vault.yml (encrypted) ---
if [[ ! -f "$VAULT_GV" ]]; then
  tmpfile="$(mktemp)"
  cat >"$tmpfile" <<'YAML'
# Edit with:
#   ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
#   ansible-vault edit ansible/group_vars/all/vault.yml

# Domain creds (fill these in)
vault_domain_admin_user: "Administrator"
vault_domain_admin_password: "CHANGE_ME"

# Optional: passphrase for Linux key (if used)
vault_linux_privkey_passphrase: ""

# Host map for simple host_vars (auto-updated by ansible-init.sh)
ansible_host_map: {}
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

# --- inventory: hyperv_inventory.ps1 (minimal stub) ---
if [[ ! -f "$HV_INV" ]]; then
  cat >"$HV_INV" <<'POWERSHELL'
#!/usr/bin/env pwsh
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

# --- inventory: static_hosts.yml (example) ---
if [[ ! -f "$STATIC_INV" ]]; then
  cat >"$STATIC_INV" <<'YAML'
all:
  children:
    windows:
      hosts: {}
    linux:
      hosts: {}
YAML
  echo "Wrote $STATIC_INV"
fi

# --- inventory: ping_hosts.ini ensure exists + [windows]/[linux] sections ---
if [[ ! -f "$PING_INV" ]]; then
  printf "[windows]\n\n[linux]\n" > "$PING_INV"
  echo "Wrote $PING_INV"
else
  grep -q "^\[windows\]" "$PING_INV" || { printf "[windows]\n\n" | cat - "$PING_INV" > "${PING_INV}.tmp" && mv "${PING_INV}.tmp" "$PING_INV"; }
  grep -q "^\[linux\]" "$PING_INV"   || printf "\n[linux]\n" >> "$PING_INV"
fi

# --- helper: update ansible_host_map in encrypted vault ---
update_vault_host_map() {
  local alias="$1" ip="$2"
  local tmp_plain tmp_new
  tmp_plain="$(mktemp)"
  tmp_new="$(mktemp)"

  ansible-vault view --vault-password-file "$VAULT_PASS_FILE" "$VAULT_GV" > "$tmp_plain"

  awk -v host="$alias" -v addr="$ip" '
    BEGIN{in_map=0; updated=0; saw_map=0}
    /^ansible_host_map:[[:space:]]*$/ { print; in_map=1; saw_map=1; next }
    in_map && /^[^[:space:]]/ {                  # leaving map
      if (!updated) { print "  " host ": " addr; updated=1 }
      in_map=0
    }
    in_map {
      if ($0 ~ "^[[:space:]]{2}" host ":[[:space:]]*") {
        print "  " host ": " addr; updated=1; next
      }
    }
    { print }
    END{
      if (!saw_map) {
        print ""
        print "ansible_host_map:"
        print "  " host ": " addr
      } else if (in_map && !updated) {
        print "  " host ": " addr
      }
    }
  ' "$tmp_plain" > "$tmp_new"

  ansible-vault encrypt --vault-password-file "$VAULT_PASS_FILE" "$tmp_new" --output "$VAULT_GV" >/dev/null
  rm -f "$tmp_plain" "$tmp_new"
  echo "Updated ansible_host_map in $(realpath "$VAULT_GV") with $alias: $ip"
}

# --- Add hosts passed via --host ---
if [[ ${#HOSTS[@]} -gt 0 ]]; then
  for pair in "${HOSTS[@]}"; do
    alias="${pair%%=*}"
    ip="${pair#*=}"
    if [[ -z "$alias" || -z "$ip" || "$alias" == "$ip" ]]; then
      echo "Skipping malformed --host '$pair' (use alias=ip)"; continue
    fi

    # host_vars/<alias>/main.yml
    d="$HV_DIR/$alias"
    f="$d/main.yml"
    mkdir -p "$d"
    if [[ ! -f "$f" ]]; then
      cat >"$f" <<YAML
ansible_host: "{{ ansible_host_map['$alias'] }}"
YAML
      echo "Wrote $f"
    else
      echo "host_vars already present: $f (skipping)"
    fi

    # Update encrypted host map in the vault
    update_vault_host_map "$alias" "$ip"

    # Append to inventory/ping_hosts.ini under [windows] (no duplicates)
    if ! awk -v host="$alias" '
      $0 ~ /^\[windows\]/ { in_win=1; next }
      $0 ~ /^\[/ { in_win=0 }
      in_win && $0 ~ ("^"host"([[:space:]]*$|[[:space:]=])") { found=1 }
      END { exit(!found) }' "$PING_INV"; then
      awk -v host="$alias" '
        BEGIN{done=0}
        /^\[windows\]/{print; print host; done=1; next}
        {print}
        END{if(!done) print "[windows]\n" host}
      ' "$PING_INV" > "${PING_INV}.tmp" && mv "${PING_INV}.tmp" "$PING_INV"
      echo "Added $alias to $PING_INV [windows]"
    else
      echo "$alias already listed in $PING_INV [windows] (skipping)"
    fi
  done
fi

echo
echo "✅ Bootstrap complete."
echo "Repo root:    $REPO_ROOT"
echo "Ansible dir:  $ANS_DIR"
echo
echo "Next steps:"
echo "  1) Put real secrets in the vault:"
echo "     ANSIBLE_VAULT_PASSWORD_FILE=$(realpath --relative-to=\"$REPO_ROOT\" \"$VAULT_PASS_FILE\" 2>/dev/null || echo \"$VAULT_PASS_FILE\") \\"
echo "       ansible-vault edit $(realpath --relative-to=\"$REPO_ROOT\" \"$VAULT_GV\" 2>/dev/null || echo \"$VAULT_GV\")"
echo "  2) Test ping:"
echo "     ansible -i ansible/inventory/ping_hosts.ini windows -m ansible.windows.win_ping"
