@minLength(3)
@maxLength(24)
@sys.description('The name of the Storage Account.')
#disable-next-line BCP334
param name string = take(deployment().name, 24)
@metadata({
  strongType: 'Microsoft.Network/virtualNetworks/subnets'
})
@sys.description('The subnet to connect a private endpoint.')
param subnetId string = ''

@allowed([
  'Deny'
  'Allow'
])
@sys.description('Deny or allow network traffic unless explicitly allowed.')
param defaultFirewallAction string = 'Deny'

@metadata({
  example: [
    'x.x.x.x'
  ]
})
@sys.description('Firewall rules to permit specific IP addresses access to storage.')
param firewallIPRules string[] = []

@metadata({
  example: [
    '/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/VNET_NAME/subnets/SUBNET_NAME'
  ]
})
@sys.description('A list of resource IDs to subnets that are permitted access to storage. For each entry, a service endpoint firewall rule is created for the subnet.')
param firewallVirtualNetworkRules string[] = []

@metadata({
  ignore: true
})
@sys.description('Determines if large file shares are enabled. This can not be disabled once enabled.')
param useLargeFileShares bool = false

@sys.description('Determines if any containers can be configured with the anonymous access types of blob or container. By default, anonymous access to blobs and containers is disabled (`false`).')
param allowBlobPublicAccess bool = false

@sys.description('Determines if access keys and SAS tokens can be used to access storage. By default, access keys and SAS tokens are disabled (`false`).')
param allowSharedKeyAccess bool = false

@sys.description('Determines if the Azure Portal defaults to OAuth.')
param defaultToOAuthAuthentication bool = true

@sys.description('Additional tags to apply to the resource. Tags from the resource group will automatically be applied.')
param tags object = {}

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string

@sys.description('The type of storage to use.')
param storageKind string = 'StorageV2'

param location string = resourceGroup().location

// Calculate storage account name using existing complex naming rules
var storageAccountName = toLower(name)

// Always use large file shares if using FileStorage
var configureLargeFileShares = storageKind == 'FileStorage' ? true : useLargeFileShares
var largeFileSharesState = configureLargeFileShares ? 'Enabled' : 'Disabled'

var isFileStorage = storageKind == 'FileStorage'
var usePrivateEndpoint = !empty(subnetId)

// Configure tags
var allTags = union(resourceGroup().tags, tags)

@sys.description('Create or update a Storage Account.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSKU
  }
  kind: storageKind
  properties: {
    networkAcls: {
      defaultAction: usePrivateEndpoint ? 'Deny' : defaultFirewallAction
      bypass: 'AzureServices'
      ipRules: [for item in firewallIPRules: {
        action: 'Allow'
        value: item
      }]
      virtualNetworkRules: [for item in firewallVirtualNetworkRules: {
        action: 'Allow'

        #disable-next-line use-resource-id-functions
        id: item
      }]
      resourceAccessRules: [
        {
          tenantId: tenant().tenantId

          #disable-next-line use-resource-id-functions
          resourceId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Security/datascanners/StorageDataScanner'
        }
      ]
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
    largeFileSharesState: largeFileSharesState // Large file shares support up to 100 TiB.
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: allowSharedKeyAccess ? true : defaultToOAuthAuthentication
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: usePrivateEndpoint ? 'Disabled' : 'Enabled'
  }
  tags: allTags
}


// @sys.description('A unique identifier for the Storage Account.')
// output id string = storageAccount.id

// @sys.description('The name of the Storage Account.')
// output storageAccountName string = storageAccountName
@sys.description('A unique identifier for the Storage Account.')
output id string = storageAccount.id

@sys.description('The name of the Storage Account.')
output storageAccountName string = storageAccountName

@sys.description('The name of the Resource Group where the Storage Account is deployed.')
output resourceGroupName string = resourceGroup().name

@sys.description('The guid for the subscription where the Storage Account is deployed.')
output subscriptionId string = subscription().subscriptionId

@sys.description('The primary blob endpoint for the Storage Account.')
output blobEndpoint string = isFileStorage ? '' : storageAccount.properties.primaryEndpoints.blob
