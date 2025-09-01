targetScope = 'managementGroup' // or 'subscription'

@description('Initiative: VM Build Baseline')
param initiativeName string = 'vm-build-baseline'

@description('Built-in policy IDs')
param allowedLocationsDefId string
param requireTagDefId string
param denyPublicIPDefId string
param deployAmlLinuxDefId string
param deployAmlWindowsDefId string
param vmBackupDefId string
param allowedVmSkusDefId string

@description('Parameters for built-ins')
param listOfLocations array = ['eastus', 'eastus2']
param requiredTagName string = 'Owner'
param requiredTagValue string = 'Matt'
param allowedVmSkus array = ['Standard_D4s_v5', 'Standard_D8s_v5']

@description('Monitoring/Backup resource IDs')
param dataCollectionRuleId string = ''
param recoveryServicesVaultId string = ''

resource initiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: 'VM Build Baseline'
    description: 'Regions, tags, no public IPs, AMA, backup, allowed SKUs.'
    policyType: 'Custom'
    metadata: {
      category: 'Compute'
    }
    parameters: {
      listOfLocations:            { type: 'Array' }
      requiredTagName:           { type: 'String' }
      requiredTagValue:          { type: 'String' }
      allowedVmSkus:             { type: 'Array' }
      dataCollectionRuleId:      { type: 'String' }
      recoveryServicesVaultId:   { type: 'String' }
    }
    policyDefinitions: [
      // Allowed locations
      {
        policyDefinitionId: allowedLocationsDefId
        parameters: {
          listOfAllowedLocations: { value: listOfLocations }
        }
      }
      {
        policyDefinitionId: requireTagDefId
        parameters: {
          tagName:  { value: requiredTagName }
          tagValue: { value: requiredTagValue }
        }
      }
      {
        policyDefinitionId: denyPublicIPDefId
      }
      {
        policyDefinitionId: deployAmlLinuxDefId
        parameters: {
          // some AMA policies use different param names; adjust if needed
          dcrResourceId: { value: dataCollectionRuleId }
        }
      }

      {
        policyDefinitionId: deployAmlWindowsDefId
        parameters: {
          dcrResourceId: { value: dataCollectionRuleId }
        }
      }
      {
        policyDefinitionId: vmBackupDefId
        parameters: {
          effect:  { value: 'DeployIfNotExists' }
          vaultId: { value: recoveryServicesVaultId }
        }
      }
      {
        policyDefinitionId: allowedVmSkusDefId
        parameters: {
          listOfAllowedSKUs: { value: allowedVmSkus }
        }
      }
    ]
  }
}
