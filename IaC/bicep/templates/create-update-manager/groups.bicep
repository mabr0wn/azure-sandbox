// groups.bicep
param patchGroupName string
param tags object = {}

resource patchGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: patchGroupName
  location: resourceGroup().location
  tags: tags
}
