targetScope = 'subscription'

@description('Policy assignment for VM Build Baseline initiative')
param assignmentName string = 'vm-build-baseline-assignment'
param initiativeId string
param initiativeParams object = {}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  properties: {
    displayName: 'VM Build Baseline Assignment'
    policyDefinitionId: initiativeId
    parameters: initiativeParams
    enforcementMode: 'Default'
    scope: subscription().id
  }
  identity: {
    type: 'SystemAssigned'
  }
}
