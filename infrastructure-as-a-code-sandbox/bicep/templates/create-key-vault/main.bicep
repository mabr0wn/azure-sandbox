@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location

@description('Configures Log Analytics workspace configure for auditing for the Azure resources.')
param workspaceId string

@description('Configures the key vault name to deploy the Azure resources.')
param kvname string

@description('Configures the audit logs name to deploy the Azure resources.')
param name string

param workspaceName string

@description('Name of the Managed HSM instance.')
param hsmName string

// Deploy standard Key Vault
module kv_required_params './.modules/keyvault.bicep' = {
  name: 'kv_required_params'
  params: {
    name: kvname
    location: location
    tags: {
      env: 'prod'
    }
  }
}

// Deploy Log Analytics Workspace
module log_analytic_workspace '../create-log-analytics-workspace/.modules/log-analytics-workspace.bicep' = {
  name: 'log_analytic_workspace'
  params: {
    name: workspaceName
  }
}

// Attach audit logs to Key Vault
module audit_logs './.modules/keyvault.bicep' = {
  name: 'audit_logs'
  params: {
    name: name
    location: location
    tags: {
      env: 'prod'
    }
    workspaceId: workspaceId
  }
  dependsOn: [
    log_analytic_workspace
  ]
}

// Deploy Managed HSM with CMKs
module hsm_module './.modules/hsm.bicep' = {
  name: 'hsm_module'  // Module name

  params: {
    hsmKeyName: 'skynet-key'
    hsmName: hsmName
    keyVaultName: kvname
    adminObjectId: '<YOUR-AAD-OBJECT-ID>'  // Replace this!
    workspaceId: workspaceId
    location: location
    tags: {
      env: 'prod'
    }
  }

  dependsOn: [
    log_analytic_workspace
  ]
}

