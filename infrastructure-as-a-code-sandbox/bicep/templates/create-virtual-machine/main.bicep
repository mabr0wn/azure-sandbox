////////////////////////////////////////////////////////////////////////////////
// VM parameters
////////////////////////////////////////////////////////////////////////////////
@description('Enter the department. i.e. IT')
param dept string
@allowed([
  'prod'
  'dev'
  'test'
])
param env string
@description('Enter the virtual machine name.')
param vmName string
@allowed([
  'p'
  'd'
  't'
])
param suffix string
@description('Enter the domain.')
param domainFQDN string
@description('Enter the admin account username.')
param domainJoinUserName string
@secure()
@description('Enter the admin account password.')
param domainJoinUserPassword string
param domainJoinSecretName string
@description('Enter the azure location.')
param location string
@allowed([
  'Server2016'
  'Server2019'
  'Server2022'
  'Ubuntu1804'
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
param vmSecretName string
param subnetName string
param vnetName string
param vNetRG string
param scriptContent string
param kvname string
param storageAccountName string
param resourceGroupName string
param sshPublicKey string
@allowed([
'Premium_LRS'
'Premium_ZRS'
'Standard_GRS'
'Standard_GZRS'
'Standard_LRS'
'Standard_RAGRS'
'Standard_RAGZRS'
'Standard_ZRS'
'StandardSSD_LRS'
])
param storageAccountType string

////////////////////////////////////////////////////////////////////////////////
// Deployment vm start
////////////////////////////////////////////////////////////////////////////////
module azVirtualMachine './.modules/vm.bicep' = {
  name: 'azVirtualMachine'
  params: {
    vmName: vmName
    suffix: suffix
    domainFQDN: domainFQDN
    domainJoinUserName: domainJoinUserName
    domainJoinUserPassword: domainJoinUserPassword
    domainJoinSecretName: domainJoinSecretName
    location: location
    OS: OS
    ouPath: ouPath
    SubnetName: subnetName
    virtualMachineCount: virtualMachineCount
    kvname: kvname
    vmUserName: vmUserName
    vmPassword: vmPassword
    vmSecretName: vmSecretName
    vmSize: vmSize
    vNetName: vnetName
    vNetResourceGroup: vNetRG
    storageAccountType: storageAccountType
    scriptContent: scriptContent
    resourceGroupName: resourceGroupName
    sshPublicKey: sshPublicKey
    storageAccountName: storageAccountName
    tags: {
      dept: dept
      env: env
    }
  }
}
