#!/usr/bin/env bash
set -euo pipefail

# Run from repo root. Creates a policies/ tree and test scaffolding (idempotent).

ROOT="$(pwd)"
say() { printf "\033[1;32m[+] %s\033[0m\n" "$*"; }
note() { printf "\033[0;36m[.] %s\033[0m\n" "$*"; }
skip() { printf "\033[0;33m[=] %s\033[0m\n" "$*"; }

# 1) Create directories
mkdir -p ansible/policies/windows \
         ansible/policies/linux \
         ansible/policies/cloud \
         tests/unit/ansible/playbooks \
         tools

say "Ensured policies/ and tests/ directories exist"

# 2) Seed example policy task files (only if missing)
seed_file() {
  local path="$1" ; shift
  local content="$*"
  if [[ -e "$path" ]]; then
    skip "Exists: $path"
  else
    note "Creating $path"
    printf "%s" "$content" > "$path"
  fi
}

# --- Windows example policies ---
seed_file ansible/policies/windows/firewall.yml \
'---
# Example Windows firewall policy (inbound RDP disabled; allow WinRM)
- name: Ensure RDP inbound is disabled
  ansible.windows.win_firewall_rule:
    name: "RDP"
    enabled: yes
    state: present
    direction: in
    action: block
    localport: 3389
    protocol: TCP

- name: Ensure WinRM is allowed
  ansible.windows.win_firewall_rule:
    name: "WinRM"
    enabled: yes
    state: present
    direction: in
    action: allow
    localport: 5985-5986
    protocol: TCP
'

seed_file ansible/policies/windows/password_policy.yml \
'---
# Example Windows password policy (secedit)
- name: Set Windows password policy (min length 14)
  ansible.windows.win_security_policy:
    section: "System Access"
    key: "MinimumPasswordLength"
    value: "14"
'

# --- Linux example policies ---
seed_file ansible/policies/linux/sshd_config.yml \
'---
# Example Linux SSH hardening
- name: Ensure PasswordAuthentication is disabled
  ansible.builtin.lineinfile:
    path: /etc/ssh/sshd_config
    regexp: "^#?PasswordAuthentication"
    line: "PasswordAuthentication no"
    create: no
    backrefs: no
  notify: Restart sshd

- name: Ensure PermitRootLogin is prohibit-password
  ansible.builtin.lineinfile:
    path: /etc/ssh/sshd_config
    regexp: "^#?PermitRootLogin"
    line: "PermitRootLogin prohibit-password"
    create: no
    backrefs: no
  notify: Restart sshd
'

seed_file ansible/policies/linux/packages.yml \
'---
# Ensure baseline tools are present
- name: Install baseline packages
  ansible.builtin.package:
    name:
      - vim
      - curl
      - htop
    state: present
'

# --- Cloud example policy ---
seed_file ansible/policies/cloud/azure_tagging.yml \
'---
# Enforce baseline Azure tags via CLI or azure.azcollection (placeholder)
- name: Ensure required tags present (placeholder task)
  ansible.builtin.debug:
    msg: "Apply required tags: env, owner, costcenter"
'

# 3) Create a sample playbook to apply policies (only if missing)
seed_file ansible/playbooks/apply_policies.yml \
'---
# Apply OS-specific policy snippets by group
- hosts: windows
  gather_facts: no
  vars:
    ansible_connection: winrm
  tasks:
    - name: Include Windows firewall policy
    - include_tasks: ../policies/windows/firewall.yml
    - name: Include Windows password policy
    - include_tasks: ../policies/windows/password_policy.yml

- hosts: linux
  become: yes
  tasks:
    - name: Include Linux SSH hardening
    - include_tasks: ../policies/linux/sshd_config.yml
    - name: Include Linux baseline packages
    - include_tasks: ../policies/linux/packages.yml

# Example handler for Linux
- hosts: linux
  become: yes
  handlers:
    - name: Restart sshd
      ansible.builtin.service:
        name: sshd
        state: restarted
'

# 4) Unit test scaffolding for policies (pytest)
seed_file tests/unit/ansible/playbooks/test_policies.py \
'"""
Basic sanity checks for policy snippets.
These don\'t run remote hosts—just validate file presence and YAML parsing.
"""
import os
import glob
import yaml

BASE = os.path.join("ansible", "policies")

def test_policy_files_exist():
    expected = [
        "windows/firewall.yml",
        "windows/password_policy.yml",
        "linux/sshd_config.yml",
        "linux/packages.yml",
        "cloud/azure_tagging.yml",
    ]
    for rel in expected:
        path = os.path.join(BASE, rel)
        assert os.path.exists(path), f"Missing policy file: {path}"

def test_yaml_loads_cleanly():
    for path in glob.glob(os.path.join(BASE, "**", "*.yml"), recursive=True):
        with open(path, "r", encoding="utf-8") as f:
            try:
                yaml.safe_load(f)
            except Exception as e:
                raise AssertionError(f"Invalid YAML in {path}: {e}")
'

# 5) README pointers (optional add)
seed_file ansible/policies/README.md \
'# Ansible Policies

This directory contains small, reusable policy snippets (security, hardening, compliance).
Include them from playbooks (e.g., `playbooks/apply_policies.yml`) using `include_tasks`.
'

say "Policy scaffold complete."

note "Next steps:"
echo "  - Add hosts to inventory groups: [windows], [linux]"
echo "  - Run tests:    pytest -q tests/unit/ansible/playbooks/test_policies.py"
echo "  - Apply (linux): ansible-playbook ansible/playbooks/apply_policies.yml -l linux"
echo "  - Apply (win):   ansible-playbook ansible/playbooks/apply_policies.yml -l windows"
