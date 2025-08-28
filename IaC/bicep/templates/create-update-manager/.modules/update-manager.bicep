// update-manager.bicep

param updateScheduleName string
param location string
param configurationType string // 'LinuxPatch' or 'WindowsPatch'
param dayOfWeek string // e.g., 'Saturday'
param hour int // e.g., 3 for 3AM
param duration string // e.g., 'PT2H'
param rebootSetting string // e.g., 'IfRequired'
param vmResourceIds array
param tags object = {}

resource updateDeployment 'Microsoft.Automanage/configurationProfiles@2022-05-04-preview' = {
  name: updateScheduleName
  location: location
  tags: tags
  properties: {
    configurationType: configurationType
    configurationSettings: {
      schedule: {
        dayOfWeek: dayOfWeek
        hour: hour
        duration: duration
        rebootSetting: rebootSetting
      }
    }
    targetResourceIds: vmResourceIds
  }
}
