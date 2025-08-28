# PowerShell script content here
Write-Output "Starting custom PowerShell script execution..."

# Example: Creating a resource group
$resourceGroupName = 'myResourceGroup'
$location = 'EastUS'

Write-Output "Creating resource group: $resourceGroupName in location: $location"
New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Output "Custom PowerShell script execution completed."