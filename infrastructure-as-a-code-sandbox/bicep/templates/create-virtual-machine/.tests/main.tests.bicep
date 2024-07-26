@sys.description('Enter the department. i.e. IT')
param dept string = 'I.T.'
@allowed([
  'test'
])
param env string = 'test'
param testVmName string
@allowed([
  't'
])
param suffix string = 't'
@sys.description('Enter the domain.')
param testFQDN string = 'contoso.com'
@sys.description('Enter the admin account username.')
param domainJoinUserName string
@secure()
@sys.description('Enter the admin account password.')
param domainJoinUserPassword string
@sys.description('Enter the azure location.')
param location string
@allowed([
  'Server2016'
  'Server2019'
  'Server2022'
])
param OS string = 'Server2022'
param ouPathTest string = 'OU=Departments,DC=ad,DC=contoso,DC=com'
@sys.description('How many vm are being deployed?')
param virtualMachineCount int = 2
@sys.description('Enter the azure vm size.')
param vmSize string = 'Standard_DS1_v2'
@sys.description('Enter the azure local admin account.')
param vmUserName string = 'testadmin'
@secure()
param vmPassword string
param subnetName string = 'testSubnetName'
param vnetName string = 'testVnetName'
param vNetRG string = 'testRgName'

module testVM '../.modules/vm.bicep' = {
  name: 'testVM'
  params: {
    vmName: testVmName
    suffix: suffix
    domainFQDN: testFQDN
    domainJoinUserName: domainJoinUserName
    domainJoinUserPassword: domainJoinUserPassword
    location: location
    OS: OS
    ouPath: ouPathTest
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
