param vpnGatewayName string
//param resourceGroupName string
param vnetName string
param publicIpAddressName string
param location string
param skuName string

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2021-03-01' = {
  name: vpnGatewayName
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: skuName
    }
    publicIPAddress: {
      // The resourceId function dynamically resolves resources within the same resource group 
      // unless you explicitly scope it to another resource group or subscription.
      id: resourceId('Microsoft.Network/publicIPAddresses', publicIpAddressName)
    }
    vpnClientConfiguration: null
  }
  dependsOn: [
    publicIpAddress
    virtualNetwork
  ]
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-03-01' existing = {
  name: publicIpAddressName
  //scope: resourceGroup('<other-resource-group-name>')
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnetName
}
