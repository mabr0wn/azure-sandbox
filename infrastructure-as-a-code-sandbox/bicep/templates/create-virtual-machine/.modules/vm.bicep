param vmUserName string
@secure()
param vmPassword string
param vmSecretName string
param vmName string
param suffix string
param virtualMachineCount int
param vmSize string
param OS string
param location string
param vNetName string
param vNetResourceGroup string
param SubnetName string
param domainFQDN string
param domainJoinUserName string
param ouPath string
param storageAccountType string
@secure()
param domainJoinUserPassword string
param domainJoinSecretName string
param scriptContent string
@description('Existing keyvault name in Azure.')
param kvname string
param storageAccountName string
param resourceGroupName string

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
  Ubuntu1804: {
    PublisherValue: 'Canonical'
    OfferValue: 'UbuntuServer'
    SkuValue: '18.04-LTS'
  }
  Ubuntu2004: {
    PublisherValue: 'Canonical'
    OfferValue: 'UbuntuServer'
    SkuValue: '20_04-lts'
  }
  CentOS7_9: {
    PublisherValue: 'OpenLogic'
    OfferValue: 'CentOS'
    SkuValue: '7_9'
  }
  CentOS8_3: {
    PublisherValue: 'OpenLogic'
    OfferValue: 'CentOS'
    SkuValue: '8_3'
  }
}


@sys.description('Tags to apply to the resource.')
param tags object = resourceGroup().tags

var subnetRef = resourceId(vNetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, SubnetName)
var uniqueStringSuffix = uniqueString(resourceGroup().id)

resource virtualmachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, virtualMachineCount): {
  name: '${vmName}${i + 1}${suffix}'
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
        managedDisk: {
          storageAccountType: storageAccountType
        }
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: '${vmName}${i + 1}${suffix}'
      adminUsername: vmUserName    
      windowsConfiguration: {
        provisionVMAgent: true
      }
      adminPassword: vmPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmName}${i + 1}${suffix}-${uniqueStringSuffix}')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false        
      }
    }
  }
  tags: tags
  dependsOn: [    
    nic
  ]
}]

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = [for i in range(0, virtualMachineCount): {
  name: '${vmName}${i + 1}${suffix}-${uniqueStringSuffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    enableIPForwarding: false
  }
  tags: tags
  dependsOn: []
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
resource windowsDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, virtualMachineCount): if (contains(operatingSystemValues, 'Server')){
  name: toLower('${vmName}${i + 1}${suffix}/joindomain')
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
  dependsOn: [
    virtualmachine
  ]
}]

resource linuxDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, virtualMachineCount): if (!(contains(operatingSystemValues, 'Ubuntu') || contains(operatingSystemValues, 'CentOS'))) {
  name: toLower('${vmName}${i + 1}${suffix}/joindomain')
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://<your-storage-account-name>.blob.core.windows.net/scripts/join-linux-domain.sh' // Update with the actual URI to your script
      ]
      commandToExecute: 'bash join-linux-domain.sh'
    }
    protectedSettings: {
      storageAccountName: existingStorageAccount
      storageAccountKey: 'Eby8vdM02xNOcq7uM0sPsp6ycUQpVzQ6NQ6k6lxKTUm6Nf6p6XKwWDFk2QO47tR4B3AyRtTkcX26K4pB5+O='
      // Optionally pass domain credentials securely
      fileUris: []
    }
  }
  tags: tags
  dependsOn: [
    virtualmachine
  ]
}]

resource existingStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
  scope: resourceGroup(resourceGroupName)
}


module deploymentScript '../../create-deployment-script/.modules/externalScript.bicep' = {
  name: 'runPowerShellExternalScript'
  params: {
    location: location
    scriptContentParam: scriptContent
  }
  dependsOn: [
    windowsDomainJoin
  ]
}
