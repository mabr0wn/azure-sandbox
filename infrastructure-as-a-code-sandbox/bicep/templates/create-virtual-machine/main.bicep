////////////////////////////////////////////////////////////////////////////////
// VM parameters (non-secret)
////////////////////////////////////////////////////////////////////////////////
@description('Enter the department. i.e. IT')
param dept string
param env string
param owner string
param app string

@description('Enter the virtual machine name.')
param vmName string

@description('Enter the domain.')
param domainFQDN string

@description('Enter the domain join account username.')
param domainJoinUserName string

@description('Secret name in Key Vault for the domain join account password.')
param domainJoinSecretName string

@description('Enter the azure location.')
param location string

param OS string
param IP string
param NSG string

@description('Enter the OU path. e.g. OU=Departments,DC=ad,DC=contoso,DC=com')
param ouPath string

@description('How many VMs are being deployed?')
param virtualMachineCount int = 1

@description('Enter the Azure VM size.')
param vmSize string

@description('Enter the local admin account username.')
param vmUserName string

@description('Secret name in Key Vault for the local admin password.')
param vmSecretName string

param subnetName string
param vnetName string
param vNetResourceGroup string

@description('Existing Key Vault name.')
param kvname string

// @description('Resource group containing the Key Vault (defaults to current RG).')
// param kvResourceGroup string = resourceGroup().name

// @description('Subscription ID containing the Key Vault (defaults to current sub).')
// param kvSubscriptionId string = subscription().subscriptionId

param storageAccountName string
param resourceGroupName string
param sshPublicKey string
param storageAccountType string
// param scriptContent string

////////////////////////////////////////////////////////////////////////////////
// Deployment vm start
////////////////////////////////////////////////////////////////////////////////
module azVirtualMachine './.modules/vm.bicep' = {
  name: 'azVirtualMachine'
  params: {
    // KV context + secret names (no secret values)
    kvname: kvname
    // kvResourceGroup: kvResourceGroup
    // kvSubscriptionId: kvSubscriptionId
    vmSecretName: vmSecretName
    domainJoinSecretName: domainJoinSecretName

    // VM + networking
    vmName: vmName
    domainFQDN: domainFQDN
    domainJoinUserName: domainJoinUserName
    location: location
    OS: OS
    IP: IP
    NSG: NSG
    ouPath: ouPath
    SubnetName: subnetName
    virtualMachineCount: virtualMachineCount
    vmUserName: vmUserName
    vmSize: vmSize
    vNetName: vnetName
    vNetResourceGroup: vNetResourceGroup
    storageAccountType: storageAccountType
    resourceGroupName: resourceGroupName
    sshPublicKey: sshPublicKey
    storageAccountName: storageAccountName
    // scriptContent: scriptContent

    tags: {
      dept: dept
      env: env
      owner: owner
      app: app
    }
  }
}
