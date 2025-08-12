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
// param scriptContent string
@description('Existing keyvault name in Azure.')
param kvname string
// NEW (defaults): where the KV lives; override if different
param kvResourceGroup string = resourceGroup().name
param kvSubscriptionId string = subscription().subscriptionId

param storageAccountName string
param resourceGroupName string
param sshPublicKey string

@sys.description('Tags to apply to the resource.')
param tags object = resourceGroup().tags

// ---------- Secret lookups (Key Vault) ----------
var vmPassword = listSecret(
  resourceId(kvSubscriptionId, kvResourceGroup, 'Microsoft.KeyVault/vaults/secrets', kvname, vmSecretName),
  '2015-06-01'
).value

var domainJoinUserPassword = listSecret(
  resourceId(kvSubscriptionId, kvResourceGroup, 'Microsoft.KeyVault/vaults/secrets', kvname, domainJoinSecretName),
  '2015-06-01'
).value


// ---------- Other locals ----------
var subnetRef = resourceId(vNetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, SubnetName)
var uniqueStringSuffix = uniqueString(resourceGroup().id)
var nsgRef = resourceId(vNetResourceGroup,'Microsoft.Network/networkSecurityGroups', NSG)

// (keep your operatingSystemValues map as-is)
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
    SkuValue: '20.04-LTS'
  }
  Ubuntu2204: {
    PublisherValue: 'Canonical'
    OfferValue: 'UbuntuServer'
    SkuValue: '22.04-LTS'
  }
  Debian11: {
    PublisherValue: 'Debian'
    OfferValue: 'Debian'
    SkuValue: '11'
  }
  CentOS7: {
    PublisherValue: 'OpenLogic'
    OfferValue: 'CentOS'
    SkuValue: '7.9'
  }
  CentOS8: {
    PublisherValue: 'OpenLogic'
    OfferValue: 'CentOS'
    SkuValue: '8.3'
  }
  RHEL8: {
    PublisherValue: 'RedHat'
    OfferValue: 'RHEL'
    SkuValue: '8'
  }
  RHEL9: {
    PublisherValue: 'RedHat'
    OfferValue: 'RHEL'
    SkuValue: '9'
  }
  SLES15: {
    PublisherValue: 'SUSE'
    OfferValue: 'SLES'
    SkuValue: '15-SP3'
  }
  SLES12: {
    PublisherValue: 'SUSE'
    OfferValue: 'SLES'
    SkuValue: '12-SP5'
  }
  AlmaLinux8: {
    PublisherValue: 'AlmaLinux'
    OfferValue: 'AlmaLinux'
    SkuValue: '8'
  }
  OracleLinux7: {
    PublisherValue: 'Oracle'
    OfferValue: 'Oracle-Linux'
    SkuValue: '7.9'
  }
  OracleLinux8: {
    PublisherValue: 'Oracle'
    OfferValue: 'Oracle-Linux'
    SkuValue: '8.4'
  }
  FlatcarContainerLinux: {
    PublisherValue: 'Kinvolk'
    OfferValue: 'FlatcarContainerLinux'
    SkuValue: 'Stable'
  }
  WindowsServerCore2016: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2016-Datacenter-Core'
  }
  WindowsServerCore2019: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2019-Datacenter-Core'
  }
  WindowsServerCore2022: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2022-Datacenter-Core'
  }
  
}

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
        managedDisk: {
          storageAccountType: storageAccountType
        }
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: '${vmName}${virtualMachineCount > 1 ? (i + 1) : ''}'
      adminUsername: vmUserName 
      adminPassword: (operatingSystemValues[OS].PublisherValue == 'MicrosoftWindowsServer' ? vmPassword : null)  // Only set password for Windows VMs
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
        additionalUnattendContent: [
          {
            passName: 'OobeSystem'
            componentName: 'Microsoft-Windows-Shell-Setup'
            settingName: 'FirstLogonCommands'
            content: 'powershell.exe -ExecutionPolicy Bypass -File "./scripts/disable-domain-firewall.ps1"'
          }
        ]
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
  name: '${vmName}${virtualMachineCount > 1 ? (i + 1) : ''}${uniqueStringSuffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          // run the cli command below to see which IPs are available in azure.
          // az network nic list --resource-group $rg --query "[].{Name:name, PrivateIPs:join(',', ipConfigurations[].privateIPAddress)}" -o table
          privateIPAddress: IP
          privateIPAllocationMethod: 'static'
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    enableIPForwarding: false
    networkSecurityGroup: {
      id: nsgRef  // Use the resource ID of the existing NSG
    }
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
  dependsOn: [
    virtualmachine
  ]
}]

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
        'https://<your-storage-account-name>.blob.core.windows.net/scripts/join-linux-domain.sh' // Update with the actual URI to your script
      ]
    }
    protectedSettings: {
      commandToExecute: 'bash join-linux-domain.sh'
      storageAccountName: existingStorageAccount
      storageAccountKey: 'Eby8vdM02xNOcq7uM0sPsp6ycUQpVzQ6NQ6k6lxKTUm6Nf6p6XKwWDFk2QO47tR4B3AyRtTkcX26K4pB5+O=' // Update with actual key(dummy key)
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


// module deploymentScript '../../create-deployment-script/.modules/externalScript.bicep' = {
//   name: 'runPowerShellExternalScript'
//   params: {
//     location: location
//     scriptContentParam: scriptContent
//   }
//   dependsOn: [
//     windowsDomainJoin
//   ]
// }
