@export()
type myObjectType = {
  storagePrefix: string
  storageSKU: string
}

@export()
var myConstant = 'This is a constant value'

@export()
func sayHello(name string) string => 'Hello ${name}!'

module azStorageTest './create-storage-account/main.bicep' = {
  name: ''
  params:{
    storagePrefix: ''
    storageSKU: ''
    location: ''
    uniqueStorageName: ''
  }
}
