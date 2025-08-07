param baseName string
param locations array
param resourceGroupNames array

targetScope = 'subscription'

module rgModule 'modules/resource.bicep' = [for (name, i) in resourceGroupNames: {
  name: 'rgDeploy-${name}'
  params: {
    resourceGroupName: name
    location: locations[i]
  }
}]
