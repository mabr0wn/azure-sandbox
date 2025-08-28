param name string

module logWorkspace '.modules/log-analytics-workspace.bicep' = {
  name: 'logWorkspace'
  params:{
    name: name
  }
}
