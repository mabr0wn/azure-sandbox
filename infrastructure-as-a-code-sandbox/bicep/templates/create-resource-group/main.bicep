param baseName string
param locations array
param resourceGroupNames array

targetScope = 'subscription'

module rgModule 'modules/resource.bicep' = [for (loc, i) in locations: {
  name: 'rgDeploy-${loc}'
  params: {
    resourceGroupName: resourceGroupNames[i]
    location: loc
  }
}]
