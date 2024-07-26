// Parameters
@sys.description('The name of the Private Endpoint.')
param name string

@metadata({
  strongType: 'location'
  example: 'eastus'
})
@description('The Azure region to deploy to.')
param location string = resourceGroup().location

@sys.description('Enter the storage account name.')
param storageAccountName string

@sys.description('Enter the SKU.')
param storageSKU string

@sys.description('Enter the blob name.')
param blobName string

@metadata({
  strongType: 'Microsoft.Network/privateDnsZones'
})
@sys.description('The private DNS zone to register the private endpoint within.')
param privateDnsZoneId string = ''

@sys.description('The unique resource identifer for the resource to expose through the Private Endpoint.')
param resourceId string

@sys.description('The unique resource identifer for the subnet to join the private endpoint to.')
param subnetId string

@allowed([
  'blob'
  'file'
  'table'
  'queue'
])
@description('The sub-resources to register the Private Endpoint for.')
param groupId string

// Storage Account
module storageAccount '../modules/storage.bicep' = {
  name: storageAccountName
  params:{
    name: storageAccountName
    storageSKU: storageSKU
    location: location
    tags: {
      env: 'prod'
    }
  }
}

// Blob Service
@sys.description('Configure blob services for the Storage Account.')
module blobService '../../create-blob-service/modules/blob-service.bicep' = {
  name: blobName
  params: {
    blobname: blobName
  }
  dependsOn:[
    storageAccount
  ]
}

// Private Endpoint
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: name
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: resourceId
          groupIds:  [groupId]
        }
      }
    ]
  }
}

@description('Configures DNS for the Private Endpoint.')
resource endpointGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = if (!empty(privateDnsZoneId)) {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: replace(last(split(privateDnsZoneId, '/')), '.', '-')
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Outputs
@description('A unique identifier for the Private Endpoint.')
output id string = privateEndpoint.id

@description('The name of the associated Private DNS Zone.')
output privateDnsZone string = last(split(privateDnsZoneId, '/'))

@description('The name of the Resource Group where the Private Endpoint is deployed.')
output resourceGroupName string = resourceGroup().name

@description('The guid for the subscription where the Private Endpoint is deployed.')
output subscriptionId string = subscription().subscriptionId
