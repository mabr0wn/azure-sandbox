# ===== Makefile =====
SHELL := /bin/bash
ANSIBLE_DIR := ansible
INVENTORY_DIR := $(ANSIBLE_DIR)/inventory
VAULT_PASS_FILE := .vault-pass.txt
PLAY_CONFIGURE := $(ANSIBLE_DIR)/playbooks/configure_vm.yml
PLAY_PATCH := $(ANSIBLE_DIR)/playbooks/monthly_patch.yml
BICEP_DIR := infrastructure-as-a-code-sandbox/bicep/templates/create-virtual-machine
PARAM_FILE := $(BICEP_DIR)/main.bicepparam

# =========
# INVENTORY & PLAYBOOKS
# =========
INV := ansible/inventory/ping_hosts.ini
PING_TEST := ansible/playbooks/ping_test.yml

# Default environment
export ANSIBLE_CONFIG := $(ANSIBLE_DIR)/ansible.cfg
export ANSIBLE_VAULT_PASSWORD_FILE := $(VAULT_PASS_FILE)

# =========
# HELP
# =========
.PHONY: help
help:
	@echo "Common commands:"
	@echo "  make bootstrap               # Create group_vars + vaulted password file"
	@echo "  make deps                    # Install Ansible (with Azure) + tools"
	@echo "  make write-secrets           # Write Vault pass + SSH key from env vars"
	@echo "  make inventory-graph         # Show merged inventory (static)"
	@echo "  make ping-windows            # Run ping_test.yml against Windows hosts"
	@echo "  make ping-linux              # Run ping_test.yml against Linux hosts"
	@echo "  make ping-all                # Run ping_test.yml against all hosts"
	@echo "  make win-ping                # Direct win_ping test for [windows] group"
	@echo "  make configure               # Run configure playbook for all"
	@echo "  make configure-win           # Configure Windows only"
	@echo "  make configure-linux         # Configure Linux only"
	@echo "  make patch-monthly           # Run monthly patch playbook"
	@echo "  make apps-win HOST=<host>    # Run Windows apps playbook for a host"
	@echo "                               # ex: make apps-win HOST=skynet-ca"
	@echo "                               # ex: make apps-win HOST=skynet-veeam"
	@echo "  make inv-graph-azure         # Show Azure dynamic inventory (on demand)"
	@echo "  make inv-graph-hyperv        # Show Hyper-V inventory (on demand)"
	@echo "  make deploy                  # Deploy VM via Bicep (uses main.bicepparam)"
	@echo "  make spot-deploy             # Example: deploy Spot VM via az cli (manual)"
	@echo "  make pwsh-install            # Install PowerShell for Hyper-V inventory"
	@echo "  make vault-edit              # Edit vaulted secrets"
	@echo "  make vault-view              # View vaulted secrets (read-only)"

# =========
# BOOTSTRAP
# =========
.PHONY: bootstrap
bootstrap:
	mkdir -p $(ANSIBLE_DIR)/group_vars/all
	@[ -f $(ANSIBLE_DIR)/group_vars/windows.yml ] || cat > $(ANSIBLE_DIR)/group_vars/windows.yml <<- 'YAML'
		ansible_connection: winrm
		ansible_user: Administrator
		ansible_password: "{{ vault_windows_admin_password }}"
		ansible_port: 5985
		ansible_winrm_scheme: http
		ansible_winrm_transport: basic
		ansible_winrm_server_cert_validation: ignore
		ansible_become: false
	YAML
	@[ -f $(ANSIBLE_DIR)/group_vars/linux.yml ] || cat > $(ANSIBLE_DIR)/group_vars/linux.yml <<- 'YAML'
		ansible_connection: ssh
		ansible_user: azureuser
		ansible_ssh_private_key_file: ~/.ssh/id_rsa
		ansible_ssh_pass: "{{ vault_linux_privkey_passphrase | default(omit) }}"
	YAML
	@[ -f $(VAULT_PASS_FILE) ] || (echo "CHANGE_ME" > $(VAULT_PASS_FILE) && chmod 600 $(VAULT_PASS_FILE) && echo ".vault-pass.txt" >> .gitignore)
	@[ -f $(ANSIBLE_DIR)/group_vars/all/vault.yml ] || ANSIBLE_VAULT_PASSWORD_FILE=$(VAULT_PASS_FILE) ansible-vault create $(ANSIBLE_DIR)/group_vars/all/vault.yml

# =========
# DEPS
# =========
.PHONY: deps
deps:
	sudo apt-get update
	sudo apt-get install -y python3-pip git powershell
	pip3 install --upgrade pip
	pip3 install "ansible[azure]" ansible-lint

# =========
# SECRETS
# =========
.PHONY: write-secrets
write-secrets:
	@[ -z "$$ANSIBLE_VAULT_PASS" ] || (echo "$$ANSIBLE_VAULT_PASS" > $(VAULT_PASS_FILE) && chmod 600 $(VAULT_PASS_FILE))
	@[ -z "$$LINUX_SSH_KEY" ] || (mkdir -p $$HOME/.ssh && echo "$$LINUX_SSH_KEY" > $$HOME/.ssh/id_rsa && chmod 600 $$HOME/.ssh/id_rsa)

# =========
# POWERHELL
# =========
.PHONY: pwsh-install
pwsh-install:
	sudo apt-get update && sudo apt-get install -y powershell

# =========
# INVENTORY (STATIC BY DEFAULT)
# =========
.PHONY: inventory-graph
inventory-graph:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-inventory -i $(INV) --graph

.PHONY: inv-graph-azure
inv-graph-azure:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-inventory -i $(INVENTORY_DIR)/azure/azure_rm.yml --graph

.PHONY: inv-graph-hyperv
inv-graph-hyperv:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-inventory -i $(INVENTORY_DIR)/hyperv_inventory.ps1 --graph

# =========
# PING TESTS
# =========
.PHONY: ping-windows
ping-windows:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -i $(INV) $(PING_TEST) --limit windows

.PHONY: ping-linux
ping-linux:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -i $(INV) $(PING_TEST) --limit linux

.PHONY: ping-all
ping-all:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -i $(INV) $(PING_TEST)

.PHONY: win-ping
win-ping:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible -i $(INV) windows -m ansible.windows.win_ping

# =========
# CONFIGURE / PATCH
# =========
.PHONY: configure
configure:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -i $(INV) $(PLAY_CONFIGURE)

.PHONY: configure-win
configure-win:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -i $(INV) $(PLAY_CONFIGURE) --limit windows

.PHONY: configure-linux
configure-linux:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -i $(INV) $(PLAY_CONFIGURE) --limit linux

.PHONY: patch-monthly
patch-monthly:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -i $(INV) $(PLAY_PATCH)

# =========
# WINDOWS APP DEPLOY
# =========
.PHONY: apps-win
apps-win:
	@if [ -z "$(HOST)" ]; then \
	  echo "Usage: make apps-win HOST=<hostname>"; \
	  echo "Examples:"; \
	  echo "  make apps-win HOST=skynet-ca"; \
	  echo "  make apps-win HOST=skynet-veeam"; \
	  echo "  make apps-win HOST=skynet-addns"; \
	  exit 1; \
	fi
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES \
	ansible-playbook -i $(INV) $(ANSIBLE_DIR)/playbooks/apps-windows.yml \
	  --limit $(HOST) -e ansible_become=false

# =========
# VAULT
# =========
.PHONY: vault-edit
vault-edit:
	ANSIBLE_VAULT_PASSWORD_FILE=$(VAULT_PASS_FILE) ansible-vault edit $(ANSIBLE_DIR)/group_vars/all/vault.yml

.PHONY: vault-view
vault-view:
	ANSIBLE_VAULT_PASSWORD_FILE=$(VAULT_PASS_FILE) ansible-vault view $(ANSIBLE_DIR)/group_vars/all/vault.yml

# =========
# BICEP DEPLOY
# =========
.PHONY: deploy
deploy:
	@if [ -z "$$AZ_RG" ]; then echo "Usage: AZ_RG=<resourceGroup> make deploy"; exit 1; fi
	az deployment group create \
	  --resource-group "$$AZ_RG" \
	  --template-file $(BICEP_DIR)/main.bicep \
	  --parameters @$(PARAM_FILE) \
	  --name vm-deploy-$$RANDOM

# =========
# SPOT DEPLOY
# =========
.PHONY: spot-deploy
spot-deploy:
	@if [ -z "$$RG" ] || [ -z "$$VM" ]; then \
	  echo "Usage: RG=<resourceGroup> VM=<vmName> make spot-deploy"; exit 1; fi
	az vm create \
	  -g $$RG -n $$VM \
	  --image Ubuntu2204 \
	  --size Standard_D4s_v5 \
	  --priority Spot \
	  --max-price -1 \
	  --eviction-policy Deallocate \
	  --admin-username azureuser \
	  --ssh-key-values $$HOME/.ssh/id_rsa.pub
