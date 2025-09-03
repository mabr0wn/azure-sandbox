using 'main.bicep'

// main.bicepparam
param updateScheduleName = 'patch-saturday-3am'
param location = 'eastus'
param configurationType = 'LinuxPatch'
param dayOfWeek = 'Saturday'
param hour = 3
param duration = 'PT2H'
param rebootSetting = 'IfRequired'
param vmResourceIds = [
  '/subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.Compute/virtualMachines/vm1'
  '/subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.Compute/virtualMachines/vm2'
]
param tags = {
  env: 'prod'
}
