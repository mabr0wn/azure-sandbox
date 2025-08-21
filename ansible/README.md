# Ansible Automation Guide

This directory contains all Ansible playbooks, inventory files, and configurations for managing VMs across **Azure, Hyper-V, and hybrid environments**.

---

## 📂 Structure

* **inventory/**
  Contains static and dynamic inventory sources (Azure, Hyper-V, etc.).

* **group\_vars/**
  Group-level variables:

  * `windows.yml` → Windows defaults
  * `linux.yml` → Linux defaults
  * `all/vault.yml` → Encrypted secrets (shared across all groups)

* **host\_vars/**
  Host-specific variables (generated automatically by `ansible-init.sh`).

* **playbooks/**
  Main playbooks:

  * `apps-windows.yml` → Install & configure Windows apps (Azure build)
  * `configure_vm.yml` → Apply baseline config
  * `monthly_patch.yml` → Run patching tasks

* **tools/**

  * `ansible-init.sh` → Bootstrap inventories, vaults, and host vars
  * Other helper scripts (inventory generation, etc.)

* **ansible.cfg**
  Default configuration for inventory path, connection details, privilege escalation, etc.

* **Makefile**
  Common automation targets (ping, configure, patch, deploy).

---

## 🔐 Vault Management

Sensitive values (admin passwords, SSH passphrases, API keys) are stored in `group_vars/all/vault.yml`, encrypted with **Ansible Vault**.

### Create Vault

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
ansible-vault create ansible/group_vars/all/vault.yml
```

### Edit Vault

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
ansible-vault edit ansible/group_vars/all/vault.yml
```

### View Vault

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
ansible-vault view ansible/group_vars/all/vault.yml
```

### Vault Password File

```bash
echo "CHANGE_ME" > .vault-pass.txt
chmod 600 .vault-pass.txt
echo ".vault-pass.txt" >> .gitignore
```

---

## ⚡ Bootstrapping with `ansible-init.sh`

Quickly initialize a new inventory and host vars:

```bash
tools/ansible-init.sh \
  --vault-pass .vault-pass.txt \
  --host skynet-ca=172.16.3.154 \
  --host skynet-veeam=172.16.3.156 \
  --host skynet-addns=172.16.3.105
```

This will:

* Ensure `ansible.cfg`, `group_vars`, `host_vars` exist
* Create `all/vault.yml` if missing
* Add per-host vaulted files under `host_vars/`
* Leave a ready-to-run inventory

Validate:

```bash
make inventory-graph
```

---

## ⚡ Running Playbooks

### Ping

```bash
make ping-linux
make ping-windows
```

### Configure

```bash
make configure
make configure-linux
make configure-win
```

### Windows App Install (Azure build)

```bash
ansible-playbook -i ansible/inventory playbooks/apps-windows.yml -l skynet-veeam
```

### Patching

```bash
make patch-monthly
```

---

## 🚀 Deployment Notes

* Use **Makefile** for day-to-day tasks (`make help` for options).
* `ansible-init.sh` lets you declare and generate new hosts quickly.
* GitHub Actions workflows can call Make targets for CI/CD.
* Azure VM deployment via Bicep supported (`make deploy`).

---

## ✅ Best Practices

* Always **encrypt secrets** in `group_vars/all/vault.yml`.
* Never commit `.vault-pass.txt` to Git.
* Run `ansible-lint` before committing.
* Use `make inventory-graph` to visualize your inventory.

---

## 📝 Example: Adding a Secret

1. Edit vault:

   ```bash
   ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
   ansible-vault edit ansible/group_vars/all/vault.yml
   ```

2. Add variable:

   ```yaml
   vault_linux_privkey_passphrase: "AnotherSecretPass"
   ```

3. Reference in `linux.yml`:

   ```yaml
   ansible_ssh_pass: "{{ vault_linux_privkey_passphrase }}"
   ```
