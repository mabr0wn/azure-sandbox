// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-import
// Import the resources and outputs from exports.bicep

module exports './exports.bicep' = {
  name: 'exports'
  params: {}
}
