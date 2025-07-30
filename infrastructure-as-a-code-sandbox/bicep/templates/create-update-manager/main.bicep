// main.bicep
param updateScheduleName string
param location string = resourceGroup().location
param configurationType string // 'LinuxPatch' or 'WindowsPatch'
param dayOfWeek string
param hour int
param duration string = 'PT2H'
param rebootSetting string = 'IfRequired'
param vmResourceIds array
param tags object = {}

module patchGroup './.modules/update-manager.bicep' = {
  name: 'patchGroup'
  params: {
    updateScheduleName: updateScheduleName
    location: location
    configurationType: configurationType
    dayOfWeek: dayOfWeek
    hour: hour
    duration: duration
    rebootSetting: rebootSetting
    vmResourceIds: vmResourceIds
    tags: tags
  }
}
