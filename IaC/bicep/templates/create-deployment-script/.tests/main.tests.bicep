
param identity string = 'UserAssigned'
param utcValue string = utcNow()
param storageAccountName string


resource testPowerShellInline 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'testPowerShellInline'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  identity: {
    type: identity
    userAssignedIdentities: {
      '/subscriptions/0000000-00AA-AAAA-0000-000000AAAAAA/resourceGroups/myResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myID': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    containerSettings: {
      containerGroupName: 'mycustomaci'
    }
    storageAccountSettings: {
      storageAccountName: storageAccountName
      storageAccountKey: 'testKey'
    }
    azPowerShellVersion: '8.3'
    arguments: '-name \\"Test User\\"'
    environmentVariables: [
      {
        name: 'UserName'
        value: '_testuser'
      }
      {
        name: 'Password'
        secureValue: 'P@ssword01'
      }
    ]
    scriptContent: '''
      param([string] $name)
      $output = \'Hello {0}. The username is {1}, the password is {2}.\' -f $name,\${Env:UserName},\${Env:Password}
      Write-Output $output
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs[\'text\'] = $output
    ''' // or "primaryScriptUri": "https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/deployment-script/deploymentscript-helloworld.ps1",
    supportingScriptUris: []
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
