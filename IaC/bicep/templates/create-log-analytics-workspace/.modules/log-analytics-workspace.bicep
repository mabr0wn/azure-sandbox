param name string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: resourceGroup().location
  properties: {}
}

output workspaceId string = logAnalyticsWorkspace.id

