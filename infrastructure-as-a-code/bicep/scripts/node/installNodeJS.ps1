# Define the version and download URL
$nodeVersion = "v18.17.1"  # Update this to the desired Node.js version
$nodeDownloadUrl = "https://nodejs.org/dist/$nodeVersion/node-$nodeVersion-x64.msi"

# Path to download the installer
$installerPath = "$env:TEMP\nodejs-installer.msi"

# Download the Node.js installer
Write-Output "Downloading Node.js $nodeVersion..."
Invoke-WebRequest -Uri $nodeDownloadUrl -OutFile $installerPath

# Install Node.js
Write-Output "Installing Node.js..."
Start-Process -FilePath msiexec.exe -ArgumentList "/i $installerPath /quiet /norestart" -Wait

# Remove the installer file
Remove-Item -Path $installerPath -Force

# Verify the installation
Write-Output "Verifying Node.js installation..."
$nodeVersionOutput = & "node" --version
$npmVersionOutput = & "npm" --version

Write-Output "Node.js version: $nodeVersionOutput"
Write-Output "npm version: $npmVersionOutput"

Write-Output "Node.js installation completed successfully."
