// params to create action group, activity log alert, and email address
param actionGroupName string
param activityLogAlertName string = uniqueString(resourceGroup().id)
param emailAddress string

// scope to the current subscription.
var alertScope = '/subscriptions/${subscription().subscriptionId}'

// create an action group to send a emai out for a global incident.
resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupName
    enabled: true
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

// Activity alert to look alert the email group of any service health issue in Azure globally.
resource activityLogAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlertName
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
          field: 'properties.incidentType'
          equals: 'Incident'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroup.id
          webhookProperties: {}
        }
      ]
    }
    // confirms alert will be enabled on deploy.
    enabled: true
  }
}
