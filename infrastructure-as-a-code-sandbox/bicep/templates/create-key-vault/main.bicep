@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location

module kv_required_params './modules/keyvault.bicep' = {
  name: 'kv_required_params'
  params: {
    name: 'kvskynet001'
    location: location
    tags: {
      env: 'prod'
    }
  }
}

// Log Analytics workspace configure for auditing
module audit_logws './modules/keyvault.bicep' = {
  name: 'audit_logs'
  params: {
    name: 'kvskynet002'
    location: location
    tags: {
      env: 'prod'
    }
    workspaceId: '/subscriptions/<subscription_id>/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/latest001'
  }
}
