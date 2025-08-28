
param identity string = 'UserAssigned'
param utcValue string = utcNow()
param storageAccountName string


resource inlinePowerShellInline 'Microsoft.Resources/deploymentScripts@2020-10-01' = {}
