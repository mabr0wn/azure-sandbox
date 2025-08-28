param name string = '\\"Matt Brown\\"'
param utcValue string = utcNow()
param location string = resourceGroup().location



resource runPowerShellInline 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runPowerShellInline'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '8.3'
    scriptContent: '''
      # Create the install folder
      $installPath = "$env:USERPROFILE\.bicep"
      $installDir = New-Item -ItemType Directory -Path $installPath -Force
      $installDir.Attributes += 'Hidden'

      # Fetch the latest Bicep CLI binary
      (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")

      # Add bicep to your PATH
      $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
      if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
      if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
      # Verify you can now access the 'bicep' command.
      bicep --help
      # Done

      # Fetch the latest Bicep VSCode extension
      $vsixPath = "$env:TEMP\vscode-bicep.vsix"
      (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/vscode-bicep.vsix", $vsixPath)
      # Install the extension
      code --install-extension $vsixPath
      # Clean up the file
      Remove-Item $vsixPath
      # Done
    '''
    arguments: '-name ${name}'
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
