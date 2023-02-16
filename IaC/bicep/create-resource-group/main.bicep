param location string
param resrouceGroupName string

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resrouceGroupName
  location: location
}
