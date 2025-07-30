param baseName string
param locations array

targetScope = 'subscription'

module rgModule 'modules/resource.bicep' = [for loc in locations: {
  name: 'rgDeploy-${loc}'
  params: {
    resourceGroupName: baseName
    location: loc
  }
}]
