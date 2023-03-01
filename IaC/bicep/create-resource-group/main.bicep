param location string
param resrouceGroupName string
param deployStorageAccount bool

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = if (deployStorageAccount) {
  name: resrouceGroupName
  location: location
}
