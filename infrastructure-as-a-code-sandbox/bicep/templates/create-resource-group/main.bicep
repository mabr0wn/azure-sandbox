param baseName string
param locations array
@description('Optional explicit RG names; if omitted, names are generated from baseName.')
param resourceGroupNames array = []

targetScope = 'subscription'

// Did the caller supply explicit names?
var useExplicitNames = length(resourceGroupNames) > 0

// Are we using a single location for all RGs?
var singleLoc = length(locations) == 1

// How many RGs to create:
var count = useExplicitNames
  ? length(resourceGroupNames)
  : length(locations)

// Deploy the RGs
module rgModule 'modules/resource.bicep' = [for i in range(0, count): {
  name: 'rgDeploy-${i}'
  params: {
    resourceGroupName: useExplicitNames
      ? string(resourceGroupNames[i])
      : '${baseName}-${i + 1}'
    // If only one location was supplied, use it for every RG; otherwise map by index
    location: singleLoc ? string(locations[0]) : string(locations[i])
  }
}]
