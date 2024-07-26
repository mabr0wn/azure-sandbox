@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location
@description('Configures Log Analytics workspace configure for auditing for the Azure resources.')
param workspaceId string
@description('Configures the key vault name to deploy the Azure resources.')
param kvname string
@description('Configures the audit logs name to deploy the Azure resources.')
param name string

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

// Log Analytics workspace configure for auditing
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
}
