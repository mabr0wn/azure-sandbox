@description('Basic, Standard or Premium tier')
@allowed([ 'Basic', 'Standard', 'Premium' ])
param firewallTier string = 'Premium'

param disableBgpRoutePropagation bool = false

@description('Additional IP addresses or subnets to add in the firewall rules')
param allowIpAddresses array = []

var routeTables_all_to_firewall = 'all-to-firewall'

param hubName string  // = 'vnet-hub-prod-eastus2'
param spoke01Name string // = 'peer-fosa-hub-eastus2'
param spoke02Name string // = 'peer-infra-hub-eastus2'

param location string = 'eastus2'

@description('Give your firewall a name.')
param firewallName string // = 'fosa-firewall'
var firewallIPName = 'fosa-firewall-ip'
var firewallIpAddress = '10.12.3.4' // ??

module fwPolicy './fw-policy.bicep' = {
  name: 'fwPolicyDeploy'
  params: {
    firewallTier: firewallTier
    location: location
    allowIpAddresses: allowIpAddresses
  }
}

resource routeTable 'Microsoft.Network/routeTables@2020-05-01' = {
  name: routeTables_all_to_firewall
  location: location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [
      {
        name: 'all-to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
        }
      }
    ]
  }
}

resource routeTableGateway 'Microsoft.Network/routeTables@2020-05-01' = {
  name: 'gateway-route'
  location: location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [
      {
        name: 'peer-fosa-hub-eastus2'
        properties: {
          addressPrefix: '10.190.24.0/22'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
        }
      }
      {
        name: 'peer-infra-hub-eastus2'
        properties: {
          addressPrefix: '10.190.32.0/22'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
        }
      }
    ]
  }
}

resource subnetS01default 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${spoke01Name}/default'
  properties: {
    addressPrefix: '10.190.24.0/26'
    routeTable: {
      id: routeTable.id
    }
  }
}

resource subnetS01services 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${spoke01Name}/services'
  dependsOn: [ // possible race condition where the route table is being associated with two different subnets at the same time
    subnetS01default
  ]
  properties: {
    addressPrefix: '10.190.24.64/26'
    routeTable: {
      id: routeTable.id
    }
  }
}

resource subnetS02default 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${spoke02Name}/default'
  properties: {
    addressPrefix: '10.190.32.0/26'
    routeTable: {
      id: routeTable.id
    }
  }
}

resource subnetS02services 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${spoke02Name}/services'
  dependsOn: [ // possible race condition where the route table is being associated with two different subnets at the same time
    subnetS02default
  ]
  properties: {
    addressPrefix: '10.190.32.64/26'
    routeTable: {
      id: routeTable.id
    }
  }
}


resource subnetGateway 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${hubName}/GatewaySubnet'
  properties: {
    addressPrefix: '10.190.8.0/21'
    routeTable: {
      id: routeTableGateway.id
    }
  }
}

resource firewallIP 'Microsoft.Network/publicIPAddresses@2019-09-01' = {  
  name: firewallIPName
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

resource azureFirewalls_lab_firewall_name_resource 'Microsoft.Network/azureFirewalls@2022-07-01' = {
  name: firewallName
  location: location
  properties: {
      sku: { name: 'AZFW_VNet', tier: firewallTier }
      ipConfigurations: [ {
          name: 'ipconfig1'
          properties: { 
            subnet: { id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubName, 'AzureFirewallSubnet') }
            publicIPAddress: { id: firewallIP.id } 
          }
        }
      ]
      firewallPolicy: {
          id: fwPolicy.outputs.policyid
    }
  }
}
