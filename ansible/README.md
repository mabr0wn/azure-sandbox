# Ansible Automation Guide

This directory contains all Ansible playbooks, inventory files, and configurations for managing VMs across Azure, Hyper-V, and hybrid environments.

---

## 📂 Structure

- **inventory/**  
  Contains static and dynamic inventory sources (Azure, Hyper-V, etc.).

- **group_vars/**  
  Host group–specific variables. Includes `windows.yml`, `linux.yml`, and `vault.yml` (sensitive, encrypted).

- **playbooks/**  
  Main playbooks for configuration and patching:
  - `configure_vm.yml` → Apply baseline configuration.
  - `monthly_patch.yml` → Run monthly patching tasks.

- **ansible.cfg**  
  Config file setting defaults such as inventory path and connection details.

---

## 🔐 Vault Management

Sensitive values (admin passwords, SSH passphrases, API keys) are stored in `group_vars/vault.yml`, encrypted with **Ansible Vault**.

### Create a Vault File
If you don’t already have one:
```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
ansible-vault create ansible/group_vars/vault.yml
````

You will be dropped into your default editor to add variables, e.g.:

```yaml
vault_windows_admin_password: "SuperSecret123"
vault_linux_privkey_passphrase: "MyKeyPass"
```

### Edit an Existing Vault

To safely edit:

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
ansible-vault edit ansible/group_vars/vault.yml
```

### View Vault Contents

(Read-only mode, no accidental edits):

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
ansible-vault view ansible/group_vars/vault.yml
```

### Vault Password File

The file `.vault-pass.txt` (ignored by Git) stores the decryption key.
Make sure it exists and is secured:

```bash
echo "CHANGE_ME" > .vault-pass.txt
chmod 600 .vault-pass.txt
echo ".vault-pass.txt" >> .gitignore
```

---

## ⚡ Running Playbooks

### Ping All Hosts

```bash
make ping-linux
make ping-windows
```

### Configure All VMs

```bash
make configure
```

### Configure Only Linux

```bash
make configure-linux
```

### Configure Only Windows

```bash
make configure-win
```

### Monthly Patching

```bash
make patch-monthly
```

---

## 🚀 Deployment Notes

* Use the provided **Makefile** for common tasks (`make help` shows all).
* GitHub Actions CI/CD workflows can call these Make targets for automated deployments.
* Azure VM deployment via Bicep is included (`make deploy`).

---

## ✅ Best Practices

* Always **encrypt secrets** in `vault.yml`.
* Never commit `.vault-pass.txt` to Git.
* Validate inventory sources before running playbooks:

  ```bash
  make inventory-graph
  ```
* Run `ansible-lint` regularly to ensure playbook quality.

---

## 📝 Quick Example

Adding a new secret (Linux SSH key passphrase):

1. Edit the vault:

   ```bash
   ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass.txt \
   ansible-vault edit ansible/group_vars/vault.yml
   ```

2. Insert the variable:

   ```yaml
   vault_linux_privkey_passphrase: "AnotherSecretPass"
   ```

3. Reference it in `linux.yml`:

   ```yaml
   ansible_ssh_pass: "{{ vault_linux_privkey_passphrase }}"
   ```
