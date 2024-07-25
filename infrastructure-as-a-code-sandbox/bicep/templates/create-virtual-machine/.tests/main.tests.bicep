////////////////////////////////////////////////////////////////////////////////
// VM parameters
////////////////////////////////////////////////////////////////////////////////
@description('Enter the department. i.e. IT')
param dept string
@allowed([
  'test'
])
param env string
param vmName string
@allowed([
  't'
])
param suffix string
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
param OS string = 'Server2022'

@description('How many vm are being deployed?')
param virtualMachineCount int = 2
@description('Enter the azure vm size.')
param vmSize string = 'Standard_DS1_v2'
@description('Enter the azure local admin account.')
param vmUserName string
@secure()
param vmPassword string
param subnetName string
param vnetName string
param vNetRG string

////////////////////////////////////////////////////////////////////////////////
// Deployment vm start
////////////////////////////////////////////////////////////////////////////////
module testVirtualMachine '../modules/vm.bicep' = {
  name: 'azVirtualMachine'
  params: {
    vmName: vmName
    suffix: suffix
    domainFQDN: 'test.local'
    domainJoinUserName: domainJoinUserName
    domainJoinUserPassword: domainJoinUserPassword
    location: location
    OS: OS
    ouPath: 'OU=Departments,DC=ad,DC=contoso,DC=com'
    SubnetName: subnetName
    virtualMachineCount: virtualMachineCount
    vmUserName: vmUserName
    vmPassword: vmPassword
    vmSize: vmSize
    vNetName: vnetName
    vNetResourceGroup: vNetRG
    tags: {
      dept: dept
      env: env
    }
  }
}
