param vmUserName string
//param tags object
@secure()
param vmPassword string
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
@secure()
param domainJoinUserPassword string

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
          storageAccountType: 'StandardSSD_LRS'
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
  //tags: tags
  dependsOn: []
}]

resource domainName 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, virtualMachineCount): {
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
  //tags: tags
  dependsOn: [
    virtualmachine
  ]
}]

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runCustomPowerShellScript'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '3.0' // Specify the desired Azure PowerShell version
    // can load custom script content or the triple backticks (```) to include the content of the script directly within the Bicep template.
    // scriptContent: loadTextContent('customScript.ps1')
    scriptContent: '''
      # PowerShell script content here
      Write-Output "Starting custom PowerShell script execution..."
      
      # Example: Creating a resource group
      $resourceGroupName = 'myResourceGroup'
      $location = 'EastUS'
      
      Write-Output "Creating resource group: $resourceGroupName in location: $location"
      New-AzResourceGroup -Name $resourceGroupName -Location $location
      
      Write-Output "Custom PowerShell script execution completed."
    '''
    timeout: 'PT30M' // Timeout for the script execution
    cleanupPreference: 'OnSuccess' // Cleanup resources after successful execution
    retentionInterval: 'P1D' // Retain resources for 1 day after execution
  }
  dependsOn: [
    domainName
  ]
}
