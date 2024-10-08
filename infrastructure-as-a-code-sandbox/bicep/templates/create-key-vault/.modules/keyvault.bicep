// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'
metadata name = 'Key Vault'
metadata description = 'Create or update an Azure Key Vault.'
metadata version = '1.0.0'

@sys.description('The name of the Key Vault.')
param name string
@metadata({
  strongType: 'Microsoft.Network/virtualNetworks/subnets'
})
@sys.description('The subnet to connect a private endpoint.')
param subnetId string = ''

@metadata({
  strongType: 'location'
})
@sys.description('The Azure region to deploy to.')
param location string = resourceGroup().location

@allowed([
  'Deny'
  'Allow'
])
@sys.description('Deny or allow network traffic unless explicitly allowed.')
param defaultFirewallAction string = 'Deny'

@metadata({
  example: [
    'x.x.x.x'
  ]
})
@sys.description('Firewall rules to permit specific IP addresses access to keyvault.')
param firewallIPRules string[] = []

@metadata({
  example: [
    {
      objectId: '<object_id>'
      tenantId: '<tenant_id>'
      permissions: {
        secrets: [
          'Get'
          'List'
          'Set'
        ]
      }
    }
  ]
})
@sys.description('The access policies defined for this vault.')
param accessPolicies array = []

@sys.description('Determines if Azure can deploy certificates from this Key Vault.')
param useDeployment bool = true

@sys.description('Determines if templates can reference secrets from this Key Vault.')
param useTemplate bool = true

@sys.description('Determines if this Key Vault can be used for Azure Disk Encryption.')
param useDiskEncryption bool = true

@sys.description('Determine if soft delete is enabled on this Key Vault.')
param useSoftDelete bool = true

@sys.description('Determine if purge protection is enabled on this Key Vault.')
param usePurgeProtection bool = true

@minValue(7)
@maxValue(90)
@sys.description('The number of days to retain soft deleted vaults and vault objects.')
param softDeleteDays int = 90

@sys.description('Determines if access to the objects granted using RBAC. When true, access policies are ignored.')
param useRBAC bool = true

@sys.description('The network firewall defined for this vault.')
param networkAcls object = {
  defaultAction: 'Deny'
  bypass: 'AzureServices'
  ipRules: []
  virtualNetworkRules: []
}

@metadata({
  strongType: 'Microsoft.OperationalInsights/workspaces'
  example: '/subscriptions/<subscription_id>/resourceGroups/<resource_group>/providers/Microsoft.OperationalInsights/workspaces/<workspace_name>'
})
@sys.description('The workspace to store audit logs.')
param workspaceId string = ''

@metadata({
  example: {
    service: '<service_name>'
    env: 'prod'
  }
})
@sys.description('Tags to apply to the resource.')
param tags object = resourceGroup().tags

var usePrivateEndpoint = !empty(subnetId)

@sys.description('Create or update a Key Vault.')
resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: useDeployment
    enabledForTemplateDeployment: useTemplate
    enabledForDiskEncryption: useDiskEncryption
    accessPolicies: !useRBAC ? accessPolicies : null
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: usePrivateEndpoint ? 'Deny' : defaultFirewallAction
      bypass: 'AzureServices'
      ipRules: [for item in firewallIPRules: {
        value: item
      }]
    }
    enableSoftDelete: useSoftDelete
    enablePurgeProtection: usePurgeProtection
    softDeleteRetentionInDays: softDeleteDays
    enableRbacAuthorization: useRBAC
  }
  tags: tags
}

@sys.description('Configure audit logs for the Key Vault.')
resource logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId)) {
  scope: vault
  name: 'logs'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

output resourceId string = vault.id
