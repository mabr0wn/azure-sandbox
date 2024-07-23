@description('Enter the name of the key-vault account.')
param name string = ''
@description('Enter the name of the key account.')
param keyName string
@description('Enter the azure location.')
param location string
@description('Enter the vault name.')
param vaultName string

module azKV './modules/keyvault.bicep' = {
  name: name
  params: {
    keyName: keyName
    vaultName: vaultName
    location: location
  }
}
