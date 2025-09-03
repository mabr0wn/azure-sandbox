# Requires Az module: Install-Module Az -Scope CurrentUser
param(
  [string]$Region = "eastus",
  [int]$MinBuffer = 32   # alert if remaining vCPUs < MinBuffer
)

$usage = Get-AzVMUsage -Location $Region
$cores = $usage | Where-Object { $_.Name.Value -eq "Total Regional vCPUs" }

if (-not $cores) {
  Write-Error "Could not read 'Total Regional vCPUs' for region $Region"
  exit 3
}

$used   = [int]$cores.CurrentValue
$limit  = [int]$cores.Limit
$remain = $limit - $used

"{0} total vCPU quota: used {1} / limit {2} (remaining {3})" -f $Region, $used, $limit, $remain

if ($remain -lt $MinBuffer) { exit 2 } else { exit 0 }

# .\quota_guard.ps1 -Region eastus -MinBuffer 32
