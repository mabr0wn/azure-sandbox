@export()
type myObjectType = {
  name: string
  storageSKU: string
}
// some small tests...
@export()
var myConstant = 'This is a constant value'

@export()
func sayHello(name string) string => 'Hello ${name}!'

module azStorageTest './create-storage-account/.modules/storage.bicep' = {
  name: 'storage-name001'
  params:{
    name: 'storage-name001'
    storageSKU: 'Standard_LRS'
    location: 'eastus'
  }
}
