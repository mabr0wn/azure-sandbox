targetScope = 'managementGroup'

@description('Initiative: RBAC Governance')
param initiativeName string = 'rbac-governance'

@description('Built-in policy IDs')
param maxOwnersDefId string
param mfaOwnersDefId string

resource initiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: 'RBAC Governance'
    description: 'Restrict Owner sprawl and enforce MFA for Owner role accounts.'
    policyType: 'Custom'
    metadata: { category: 'Identity' }
    parameters: {}
    policyDefinitions: [
      { policyDefinitionId: maxOwnersDefId }
      { policyDefinitionId: mfaOwnersDefId }
    ]
  }
}

