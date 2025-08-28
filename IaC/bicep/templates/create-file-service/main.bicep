param name string

module fileServices '.modules/file-service.bicep' = {
  name: name
  params: {
    name: 'default'
  }
}
