////////////////////////////////////////////////////////////////////////////////
// VM parameters
////////////////////////////////////////////////////////////////////////////////
// @description('Enter the prefix.')
// param prefix string
@description('Enter the department. i.e. fosa')
param dept string
@allowed([
  'prod'
  'dev'
  'test'
])
param env string
@description('Enter the virtual machine name.')
param vmName string
@description('Enter the domain.')
param domainFQDN string
@description('Enter the admin account username.')
param domainJoinUserName string
@secure()
@description('Enter the admin account password.')
param domainJoinUserPassword string
@description('Enter the azure location.')
param location string
@allowed([
  'Server2016'
  'Server2019'
  'Server2022'
])
param OS string
@description('Enter the OU path. i.e. OU=Departments,DC=ad,DC=contoso,DC=com')
param ouPath string
@description('How many vm are being deployed?')
param virtualMachineCount int
@description('Enter the azure vm size.')
param vmSize string
@description('Enter the azure local admin account.')
param vmUserName string
@secure()
param vmPassword string
param subnetName string
param vnetName string
param vNetRG string
//param metadata object
// var tags = {
//   Application: metadata.app
//   BusinessUnit: metadata.business
//   Created: metadata.created
//   Owner: metadata.owner
//   Environment: metadata.env
// }

////////////////////////////////////////////////////////////////////////////////
// Key vault parameters
////////////////////////////////////////////////////////////////////////////////
// @description('Enter the subscription Id from Azure.')
// param subscriptionId string
// param keyVaultResourceGroup string = 'rg-${dept}-misc-${env}'
// param keyVaultName string = '${prefix}-${dept}-kv-${env}'

// resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
//   name: keyVaultName
//   scope: resourceGroup(subscriptionId, keyVaultResourceGroup )
// }

////////////////////////////////////////////////////////////////////////////////
// Deployment vm start
////////////////////////////////////////////////////////////////////////////////
module azVirtualMachine './Templates/AzVM.bicep' = {
  name: 'azVirtualMachine'
  params: {
    vmName: vmName
    domainFQDN: domainFQDN
    domainJoinUserName: domainJoinUserName
    domainJoinUserPassword: domainJoinUserPassword
    location: location
    OS: OS
    ouPath: ouPath
    SubnetName: subnetName
    virtualMachineCount: virtualMachineCount
    vmUserName: vmUserName
    vmPassword: vmPassword
    vmSize: vmSize
    vNetName: vnetName
    vNetResourceGroup: vNetRG
    //tags: tags
  }
}
