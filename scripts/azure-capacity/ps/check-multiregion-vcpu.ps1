param(
  [string[]]$Regions = @("eastus","eastus2","centralus"),
  [int]$MinBuffer = 32
)

$bad = @()
foreach ($r in $Regions) {
  $u = Get-AzVMUsage -Location $r
  $c = $u | Where-Object { $_.Name.Value -eq "Total Regional vCPUs" }
  if (-not $c) { Write-Warning "No quota info for $r"; continue }
  $remain = [int]$c.Limit - [int]$c.CurrentValue
  "{0}: {1}/{2} (remaining {3})" -f $r, $c.CurrentValue, $c.Limit, $remain
  if ($remain -lt $MinBuffer) { $bad += $r }
}

if ($bad.Count -gt 0) {
  Write-Error ("Low vCPU buffer (<{0}) in: {1}" -f $MinBuffer, ($bad -join ", "))
  exit 2
}
exit 0
