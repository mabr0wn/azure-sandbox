////////////////////////////////////////////////////////////////////////////////
// VM parameters
////////////////////////////////////////////////////////////////////////////////
@description('Enter the department. i.e. IT')
param dept string
param env string
param owner string
param app string
@description('Enter the virtual machine name.')
param vmName string
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
param OS string
@description('Enter the OU path. i.e. OU=Departments,DC=ad,DC=contoso,DC=com')
param ouPath string
@description('How many vm are being deployed?')
param virtualMachineCount int = 1 // Default value is 1 if not provided
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
      owner: owner
      app: app
    }
  }
}
