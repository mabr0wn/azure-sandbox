param inSourceAddressPrefix string
param inDestinationAddressPrefix string
param outSourceAddressPrefix string
param outDestinationAddressPrefix string

module nsgConfig './.modules/nsg.bicep' = {
  name: 'nsgConfig'
  params: {
    inSourceAddressPrefix: inSourceAddressPrefix
    inDestinationAddressPrefix: inDestinationAddressPrefix
    outSourceAddressPrefix: outSourceAddressPrefix
    outDestinationAddressPrefix: outDestinationAddressPrefix
  }
}
