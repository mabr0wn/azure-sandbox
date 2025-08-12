// ---------- Params (inputs) ----------
param vmUserName string
param vmSecretName string
param vmName string
param virtualMachineCount int
param vmSize string
param NSG string
param OS string
param location string
param vNetName string
param vNetResourceGroup string
param SubnetName string
param IP string
param domainFQDN string
param domainJoinUserName string
param ouPath string
param storageAccountType string
param domainJoinSecretName string
@description('Existing keyvault name in Azure.')
param kvname string
param storageAccountName string
param resourceGroupName string
param sshPublicKey string

@secure()
param vmPassword string

@secure()
param domainJoinUserPassword string

@sys.description('Tags to apply to the resource.')
param tags object = resourceGroup().tags

// ---------- Other locals ----------
var subnetRef = resourceId(vNetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, SubnetName)
var uniqueStringSuffix = uniqueString(resourceGroup().id)
var nsgRef = resourceId(vNetResourceGroup, 'Microsoft.Network/networkSecurityGroups', NSG)

// (images map)
var operatingSystemValues = {
  Server2016: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2016-Datacenter'
  }
  Server2019: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2019-Datacenter'
  }
  Server2022: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2022-Datacenter'
  }
  Ubuntu1804: { PublisherValue: 'Canonical', OfferValue: 'UbuntuServer', SkuValue: '18.04-LTS' }
  Ubuntu2004: { PublisherValue: 'Canonical', OfferValue: 'UbuntuServer', SkuValue: '20.04-LTS' }
  Ubuntu2204: { PublisherValue: 'Canonical', OfferValue: 'UbuntuServer', SkuValue: '22.04-LTS' }
  Debian11:   { PublisherValue: 'Debian',    OfferValue: 'Debian',       SkuValue: '11' }
  CentOS7:    { PublisherValue: 'OpenLogic', OfferValue: 'CentOS',       SkuValue: '7.9' }
  CentOS8:    { PublisherValue: 'OpenLogic', OfferValue: 'CentOS',       SkuValue: '8.3' }
  RHEL8:      { PublisherValue: 'RedHat',    OfferValue: 'RHEL',         SkuValue: '8' }
  RHEL9:      { PublisherValue: 'RedHat',    OfferValue: 'RHEL',         SkuValue: '9' }
  SLES15:     { PublisherValue: 'SUSE',      OfferValue: 'SLES',         SkuValue: '15-SP3' }
  SLES12:     { PublisherValue: 'SUSE',      OfferValue: 'SLES',         SkuValue: '12-SP5' }
  AlmaLinux8: { PublisherValue: 'AlmaLinux', OfferValue: 'AlmaLinux',    SkuValue: '8' }
  OracleLinux7:{ PublisherValue: 'Oracle',   OfferValue: 'Oracle-Linux', SkuValue: '7.9' }
  OracleLinux8:{ PublisherValue: 'Oracle',   OfferValue: 'Oracle-Linux', SkuValue: '8.4' }
  FlatcarContainerLinux: { PublisherValue: 'Kinvolk', OfferValue: 'FlatcarContainerLinux', SkuValue: 'Stable' }
  WindowsServerCore2016: { PublisherValue: 'MicrosoftWindowsServer', OfferValue: 'WindowsServer', SkuValue: '2016-Datacenter-Core' }
  WindowsServerCore2019: { PublisherValue: 'MicrosoftWindowsServer', OfferValue: 'WindowsServer', SkuValue: '2019-Datacenter-Core' }
  WindowsServerCore2022: { PublisherValue: 'MicrosoftWindowsServer', OfferValue: 'WindowsServer', SkuValue: '2022-Datacenter-Core' }
}

// ---------- NIC ----------
resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = [for i in range(0, virtualMachineCount): {
  name: '${vmName}${virtualMachineCount > 1 ? (i + 1) : ''}${uniqueStringSuffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: IP
          privateIPAllocationMethod: 'Static'
          subnet: { id: subnetRef }
        }
      }
    ]
    enableIPForwarding: false
    networkSecurityGroup: { id: nsgRef }
  }
  tags: tags
}]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvname
}

resource vmPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent:keyVault
  name: '${keyVault.name}-${vmSecretName}'
  properties: {
    value: vmPassword
  }
}

resource domainJoinUserPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: '${keyVault.name}-${domainJoinSecretName}'
  properties: {
    value: domainJoinUserPassword
  }
}
// ---------- VM ----------
resource virtualmachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, virtualMachineCount): {
  name: '${vmName}${virtualMachineCount > 1 ? (i + 1) : ''}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: operatingSystemValues[OS].PublisherValue
        offer: operatingSystemValues[OS].OfferValue
        sku: operatingSystemValues[OS].SkuValue
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_OsDisk-${uniqueStringSuffix}-${i + 1}'
        createOption: 'FromImage'
        managedDisk: { storageAccountType: storageAccountType }
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: '${vmName}${virtualMachineCount > 1 ? (i + 1) : ''}'
      adminUsername: vmUserName
      adminPassword: (operatingSystemValues[OS].PublisherValue == 'MicrosoftWindowsServer' ? vmPassword : null)
      linuxConfiguration: (operatingSystemValues[OS].PublisherValue == 'Canonical' || operatingSystemValues[OS].PublisherValue == 'Debian' ? {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${vmUserName}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      } : null)
windowsConfiguration: (operatingSystemValues[OS].PublisherValue == 'MicrosoftWindowsServer' ? {
  provisionVMAgent: true
} : null)
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmName}${virtualMachineCount > 1 ? (i + 1) : ''}${uniqueStringSuffix}')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: { enabled: false }
    }
  }
  tags: tags
  dependsOn: [ nic ]
}]

// ---------- Windows domain join (only for Windows SKUs) ----------
resource windowsDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, virtualMachineCount): if (operatingSystemValues[OS].SkuValue == '2016-Datacenter' || operatingSystemValues[OS].SkuValue == '2019-Datacenter' || operatingSystemValues[OS].SkuValue == '2022-Datacenter') {
  name: toLower('${vmName}${virtualMachineCount > 1 ? (i + 1) : ''}/joindomain')
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainFQDN
      User: '${domainFQDN}\\${domainJoinUserName}'
      Restart: 'true'
      Options: 3
      OUPath: ouPath
    }
    protectedSettings: {
      Password: domainJoinUserPassword
    }
  }
  tags: tags
  dependsOn: [ virtualmachine ]
}]

// ---------- Linux (custom script example) ----------
resource linuxDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, virtualMachineCount): if (operatingSystemValues[OS].OfferValue == 'UbuntuServer') {
  name: toLower('${vmName}${virtualMachineCount > 1 ? (i + 1) : ''}/joindomain')
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: false
      timestamp: 123456789
      fileUris: [
        'https://<your-storage-account-name>.blob.core.windows.net/scripts/join-linux-domain.sh'
      ]
    }
    protectedSettings: {
      commandToExecute: 'bash join-linux-domain.sh'
      // storageAccountName/Key kept as placeholders; update/remove if not needed
      storageAccountName: existingStorageAccount.name
      storageAccountKey: 'REPLACE_WITH_REAL_KEY'
      fileUris: []
    }
  }
  tags: tags
  dependsOn: [ virtualmachine ]
}]

// ---------- Existing storage (if needed by Linux script) ----------
resource existingStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
  scope: resourceGroup(resourceGroupName)
}

resource disableFirewallExt 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  name: '${vmName}/disableFirewall'
  location: location
  dependsOn: [
    virtualmachine
    windowsDomainJoin
  ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell -ExecutionPolicy Bypass -Command "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False"'
    }
  }
}


