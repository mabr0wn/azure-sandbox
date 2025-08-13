using 'main.bicep'

// --- Fixed values (safe to commit) ---
param domainFQDN           = 'SkyN3t.local'
param kvname               = 'kv-skynet'
param domainJoinUserName   = 'AzureServiceAccount'
param domainJoinSecretName = 'domainJoinSAPassSecret'
param vmUserName           = 'SkynetAdmin'
param vmSecretName         = 'vmPasswordSecret'

// --- Secure values from Key Vault ---
param vmPassword             = az.getSecret('d3c58f05-ba94-4319-ba03-af2cde1d8529', 'sandbox-rg', kvname, vmSecretName)
param domainJoinUserPassword = az.getSecret('d3c58f05-ba94-4319-ba03-af2cde1d8529', 'sandbox-rg', kvname, domainJoinSecretName)

// --- UI-driven values ---
param vmName              = 'azskynetwin3'
param vnetName            = 'skynet-aznet'
param vNetResourceGroup   = 'sandbox-rg'
param subnetName          = 'skynet-azsubnet'
param NSG                 = 'VPN-Gateway-NSG'
param storageAccountName  = 'skynetazstg'
param vmSize              = 'Standard_D1_v2'
param storageAccountType  = 'Standard_LRS'
param OS                  = 'Server2022'
param location            = 'eastus'
param IP                  = '10.128.0.25'
param dept                = 'IT'
param env                 = 'test'
param app                 = 'VS Code'
param owner               = 'Server Team'
param ouPath              = 'OU=Windows,OU=Security_Hardened,OU=Servers,OU=Skynet Azure,OU=Skynet,DC=SkyN3t,DC=local'
param resourceGroupName   = 'sandbox-rg'
param sshPublicKey        = ''
