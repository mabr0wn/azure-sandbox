targetScope = 'subscription'

@description('Policy assignment for RBAC Governance initiative')
param assignmentName string = 'rbac-governance-assignment'
param initiativeId string
param initiativeParams object = {}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  properties: {
    displayName: 'RBAC Governance Assignment'
    policyDefinitionId: initiativeId
    parameters: initiativeParams
    enforcementMode: 'Default'
    scope: subscription().id
  }
  identity: {
    type: 'SystemAssigned'
  }
}
