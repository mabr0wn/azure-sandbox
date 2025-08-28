# Ansible Automation Guide

This directory contains all **Ansible playbooks, roles, inventory, and automated tests** for managing VMs across **Azure, Hyper-V, and hybrid environments**.

---

## 📂 Structure

* **inventory/**
  Static and dynamic inventory sources (Azure, Hyper-V, localhost for testing).

* **group\_vars/**
  Group-level variables:

  * `windows.yml` → Windows defaults
  * `linux.yml` → Linux defaults
  * `all/vault.yml` → Encrypted secrets (shared across all groups)

* **host\_vars/**
  Host-specific variables (created automatically by `ansible-init.sh`).

* **playbooks/**
  Core playbooks:

  * `apps-windows.yml` → Install & configure Windows apps
  * `configure_vm.yml` → Apply baseline config
  * `monthly_patch.yml` → Patching tasks
  * `site.yml` → Entrypoint for full role + policy application

* **roles/**
  Modular role implementations: `common/`, `browsers/`, `editors/`, `windows_setup/`, etc.

* **policies/**
  Policy-driven tasks, e.g. `windows/firewall.yml`, `windows/password_policy.yml`.

* **tests/**
  Organized into:

  * `unit/` → fast, local checks (syntax, roles directory exists, playbook parsing)
  * `integration/` → playbooks run in `--check` mode against test inventories
  * `system/` → end-to-end, runs against real cloud/hosts (Linux + Windows baselines)

* **tools/**
  Helper scripts, e.g.:

  * `ansible-init.sh` → bootstrap inventories and vaults
  * `clean-pycache.sh` → clear `__pycache__` directories

* **ansible.cfg**
  Default configuration (inventory path, roles path, escalation, etc.).

* **Makefile**
  Common automation targets (ping, configure, patch, deploy, test).

---

## 🔐 Vault Management

Sensitive values (admin passwords, API keys, certs) live in `group_vars/all/vault.yml` and are encrypted with **Ansible Vault**.

```bash
ansible-vault create ansible/group_vars/all/vault.yml
ansible-vault edit ansible/group_vars/all/vault.yml
ansible-vault view ansible/group_vars/all/vault.yml
```

Vault password file:

```bash
echo "CHANGE_ME" > .vault-pass.txt
chmod 600 .vault-pass.txt
echo ".vault-pass.txt" >> .gitignore
```

---

## 🧪 Testing with Pytest

We use **pytest** to validate playbooks, roles, and integration scenarios.

### Markers

Defined in `pytest.ini`:

* `unit` → fast, pure-Python or syntax-only checks
* `integration` → Ansible dry-runs (`--check`) for playbooks
* `system` → real cloud/host validation (requires inventory + credentials)
* `windows` / `linux` → platform-specific subsets
* `ansible` → general Ansible validation (lint, syntax)

### Run Tests

```bash
# Run all
pytest -v

# Only unit tests
pytest -m unit

# Only integration
pytest -m integration

# Windows-only
pytest -m windows
```

### Example Unit Tests

* Verify `roles/` directory exists
* Ensure playbooks parse with `ansible-playbook --syntax-check`
* Policy YAMLs load without error

### Example Integration Tests

* Run `site.yml` in `--check` mode
* Validate `windows_policy.yml` applies security policies
* Ensure `configure_vm.yml` includes required roles

### Example System Tests

* Linux baseline (`test_baseline_real.py`) — ensures SSH connectivity and basic packages
* Windows baseline (`test_apps_windows_check.py`) — verifies app installs and WinRM availability

---

## ⚡ Bootstrapping with `ansible-init.sh`

Quickly initialize new inventories:

```bash
tools/ansible-init.sh \
  --vault-pass .vault-pass.txt \
  --host skynet-ca=172.16.3.154 \
  --host skynet-veeam=172.16.3.156
```

Creates:

* `ansible.cfg` if missing
* `vault.yml` in `group_vars/all`
* Host-specific vaulted files in `host_vars/`

---

## ⚡ Running Playbooks

Ping:

```bash
make ping-linux
make ping-windows
```

Configure:

```bash
make configure-linux
make configure-win
```

Windows Apps:

```bash
ansible-playbook -i ansible/inventory playbooks/apps-windows.yml -l skynet-veeam
```

Patch:

```bash
make patch-monthly
```

---

## 🚀 Deployment Notes

* CI/CD can invoke `pytest` for validation and `make` for automation.
* Azure Bicep integration supported for VM provisioning.
* Hybrid deployments validated via integration/system tests.

---

## ✅ Best Practices

* Always **encrypt secrets** before committing.
* Run `pytest` + `ansible-lint` before PRs.
* Separate `unit`, `integration`, and `system` tests for clean pipelines.
* Maintain isolated test inventories under `tests/helpers` to avoid touching real hosts.

---

👉 This `README.md` now covers:

* **Unit + integration testing** with pytest
* **Policies** alongside playbooks
* **Scripts/tools** like `clean-pycache.sh`
* **Best practices for testing + vault use**

---
