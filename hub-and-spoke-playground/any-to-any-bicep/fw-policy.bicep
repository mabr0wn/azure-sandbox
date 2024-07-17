param allowIpAddresses array = []
param location string = 'eastus2'

@description('Basic, Standard or Premium tier')
@allowed([ 'Basic', 'Standard', 'Premium' ])
param firewallTier string = 'Premium'

var ipGroups_all_spokes_subnets_name = 'all-spokes-subnets'
var firewallPolicyName = 'my-firewall-policy'

var ipGroupAddresses = concat([
    '10.190.24.0/22'
    '10.190.32.0/22'
  ], allowIpAddresses)

resource ipGroup 'Microsoft.Network/ipGroups@2020-05-01' = {
  name: ipGroups_all_spokes_subnets_name
  location: location
  properties: {
    ipAddresses: ipGroupAddresses
  }
}

resource myFirewallPolicy 'Microsoft.Network/firewallPolicies@2020-05-01' = {
  name: firewallPolicyName
  location: location
  properties: {
      threatIntelMode: 'Alert'
      sku: {
          tier: 'Premium'
      }
    }
}

resource toInternetCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-07-01' = {
  parent: myFirewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'allow-internet-traffic-out'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: []
            destinationAddresses: []
            sourceIpGroups: [ ipGroup.id ]
          }
        ]
        name: 'internet-out-collection'
        priority: 200
      }
    ]
  }
}

resource anyToAnyCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-05-01' = {
  parent: myFirewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  dependsOn: [ toInternetCollectionGroup ] // RM deploys all the ruleCollectionGroups in parallel or at least not sequentially - https://learn.microsoft.com/en-us/answers/questions/673917/update-of-azure-firewall-policies-failes-faulted-r
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'any-to-any-collection'
        priority: 1000
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'allow-spoke-to-spoke-traffic'
            ipProtocols: [ 'Any' ]
            sourceIpGroups: [
              ipGroup.id
            ]
            destinationPorts: [
              '*'
            ]
            destinationIpGroups: [
              ipGroup.id
            ]
          }
        ]
      }
    ]
  }
}

output policyid string = myFirewallPolicy.id

