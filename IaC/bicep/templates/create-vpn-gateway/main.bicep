param vpnGatewayName string
param vnetName string
param publicIpAddressName string
param location string
param skuName string

module vngwVPN './.modules/vpngateway.bicep' = { 
  name: 'vngwVPN'
  params: {
    location: location
    vpnGatewayName: vpnGatewayName
    vnetName: vnetName
    publicIpAddressName: publicIpAddressName
    skuName: skuName
  }
}
