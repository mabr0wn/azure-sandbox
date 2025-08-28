param actionGroupName string
param activityLogAlerts_name string = 'ServiceHealthActivityLogAlert'
param location string = resourceGroup().location
param emailAddress string

var alertScope = '/subscriptions/${subscription().subscriptionId}'

resource actionGroups_name_resource 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: actionGroupName
  location: location
  tags: {
    
  }
  properties: {
    enabled: true
    groupShortName: actionGroupName
    emailReceivers: [
      {
        name: actionGroupName
        emailAddress: emailAddress
      }
    ]
    smsReceivers: []
    webhookReceivers: []
  }
}

resource activityLogAlerts_name_resource 'microsoft.insights/activityLogAlerts@2017-04-01' = {
  name: activityLogAlerts_name
  location: 'Global'
  properties: {
    scopes: [
      alertScope
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          field: 'level'
          equals: 'warning'
        }
        {
          field: 'properties.incidentType'
          equals: 'Incident'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}
