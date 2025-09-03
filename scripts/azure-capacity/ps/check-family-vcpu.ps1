param(
  [string]$Region = "eastus",
  [int]$MinBufferPerFamily = 16
)

$usage = Get-AzVMUsage -Location $Region
$families = $usage | Where-Object { $_.Name.Value -like "* Family vCPUs" }

foreach ($f in $families) {
  $name = $f.Name.Value
  $remain = [int]$f.Limit - [int]$f.CurrentValue
  "{0} -> {1}/{2} (remaining {3})" -f $name, $f.CurrentValue, $f.Limit, $remain
  if ($remain -lt $MinBufferPerFamily) { $low = $true }
}

if ($low) { exit 2 } else { exit 0 }
