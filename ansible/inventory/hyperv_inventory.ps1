#!/usr/bin/env pwsh
[CmdletBinding(PositionalBinding = $false)]
param(
  [string]$HostVarsPath = (Join-Path $PSScriptRoot '..' 'host_vars'),
  [Parameter(ValueFromRemainingArguments = $true)] $Ignore
)

$ErrorActionPreference = 'Stop'

# Patterns (tweak as you like)
$excludePattern = '(?i)(template|gold|base|_disabled)'
$windowsPattern = '(?i)(win|w2k|w10|w11|server|srv|dc|ad|dns|addns|veeam|iis|sql|ca)'

# Collect hosts from host_vars/<name>/ (requires at least one *.yml)
$windows = New-Object System.Collections.Generic.List[string]
$linux   = New-Object System.Collections.Generic.List[string]

Get-ChildItem -LiteralPath $HostVarsPath -Directory | ForEach-Object {
  $n = $_.Name
  if ($n -match $excludePattern) { return }
  $hasYaml = Get-ChildItem -LiteralPath $_.FullName -Filter *.yml -File -ErrorAction SilentlyContinue
  if (-not $hasYaml) { return }

  if ($n -match $windowsPattern) { $windows.Add($n) } else { $linux.Add($n) }
}

# ---- Legacy executable-inventory format ----
$inventory = @{
  "_meta"  = @{ "hostvars" = @{} }
  "windows" = @{ "hosts" = @($windows) }
  "linux"   = @{ "hosts" = @($linux)   }
}

$inventory | ConvertTo-Json -Depth 5
