param name string
@description('Enter the prefix of the storage account.')
param keyName string
@description('Enter the azure location.')
param location string
@description('Enter the SKU.')
param vaultName string

module azKV './modules/keyvault.bicep' = {
  name: name
  params: {
    keyName: keyName
    vaultName: vaultName
    location: location
  }

}
