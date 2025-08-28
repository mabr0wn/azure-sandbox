// Bicep template to create a Managed HSM and a Key Vault-integrated Customer-Managed Key (CMK)

@description('Name of the Managed HSM instance')
param hsmName string

@description('Azure region for the Managed HSM')
param location string = resourceGroup().location

@description('Name of the Key Vault that will reference the CMK')
param keyVaultName string

@description('Key name to be created in the Managed HSM')
param hsmKeyName string

@description('The objectId of the admin user for the HSM')
param adminObjectId string

@description('Tags to apply to all resources')
param tags object = {}

@description('The Log Analytics Workspace Resource ID for auditing logs')
param workspaceId string

// Create a Managed HSM instance
resource managedHsm 'Microsoft.KeyVault/managedHSMs@2021-04-01-preview' = {
  name: hsmName
  location: location
  sku: {
    name: 'Standard_B1'
  }
  properties: {
    tenantId: subscription().tenantId
    initialAdminObjectIds: [
      adminObjectId
    ]
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
  tags: tags
}

// Diagnostic settings for Managed HSM
resource hsmDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'hsmDiagnostics'
  scope: managedHsm
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: []
  }
  dependsOn: [
    managedHsm
  ]
}

// Create a key inside the Managed HSM
resource hsmKey 'Microsoft.KeyVault/managedHSMs/keys@2021-04-01-preview' = {
  name: '${hsmName}/${hsmKeyName}'
  properties: {
    keySize: 2048
    kty: 'RSA'
    keyOps: [
      'encrypt'
      'decrypt'
      'wrapKey'
      'unwrapKey'
    ]
  }
  dependsOn: [
    managedHsm
  ]
}

// Create a Key Vault that will reference the HSM key as CMK (optional integration example)
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enabledForDeployment: true
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
  tags: tags
}

output hsmUri string = managedHsm.properties.hsmUri
output hsmKeyId string = hsmKey.id
output keyVaultUri string = keyVault.properties.vaultUri
