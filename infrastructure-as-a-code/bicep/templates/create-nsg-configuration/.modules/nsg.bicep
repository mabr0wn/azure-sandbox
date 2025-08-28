param inSourceAddressPrefix string
param inDestinationAddressPrefix string
param outSourceAddressPrefix string
param outDestinationAddressPrefix string


resource nsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'CustomNSG'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowOnPremToAzure'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: inSourceAddressPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: inDestinationAddressPrefix
          destinationPortRange: '*'
          protocol: '*'
        }
      }
      {
        name: 'AllowAzureToOnPrem'
        properties: {
          priority: 200
          access: 'Allow'
          direction: 'Outbound'
          sourceAddressPrefix: outSourceAddressPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: outDestinationAddressPrefix
          destinationPortRange: '*'
          protocol: '*'
        }
      }
    ]
  }
}
