@description('Enter the prefix of the storage account.')
param storagePrefix string
@description('Enter the azure location.')
param location string
@description('Enter the SKU.')
param storageSKU string
@description('Enter the SKU.')
param uniqueStorageName string

module azStg './modules/storage.bicep' = {
  name: uniqueStorageName
  params:{
    storagePrefix: storagePrefix
    storageSKU: storageSKU
    location: location
  }

}
