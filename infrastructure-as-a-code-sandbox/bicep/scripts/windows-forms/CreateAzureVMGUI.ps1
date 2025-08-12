<#
.SYNOPSIS
  Create Azure VMs via Bicep with optional Git param generation.
.DESCRIPTION
  Windows Forms app that:
   - Connects to Azure (Az CLI)
   - Lets you select RG/VNet/Subnet/NSG/Storage/OS/Size/Location/etc.
   - (Option 1) Deploys immediately via `az deployment group create`
   - (Option 2) Generates `main.bicepparam` in a Git repo and pushes to a branch (no deploy)
.NOTES
  Version:        4.0
  Author:         Matt Brown (+ assistant merge)
  Change Date:    2025-08-11
  Purpose/Change: Add Git "Generate & Push" workflow, polish UI, small fixes.
#>

# -----------------------------
# Requirements
# -----------------------------
# - PowerShell 5+ (Windows)
# - Az CLI installed and logged in / or will prompt
# - git installed and repo present (for commit-only mode)
# - main.bicep present in target repo (for commit-only pipeline usage or in cwd for deploy)

# -----------------------------
# Assemblies
# -----------------------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

# -----------------------------
# Helpers
# -----------------------------
function Escape-SingleQuotes {
    param([string]$s)
    if ($null -eq $s) { return "" }
    return $s -replace "'", "''"
}

function Show-Info($msg) {
    [System.Windows.Forms.MessageBox]::Show($msg, "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
}
function Show-Warn($msg) {
    [System.Windows.Forms.MessageBox]::Show($msg, "Warning", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
}
function Show-Error($msg) {
    [System.Windows.Forms.MessageBox]::Show($msg, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
}

# -----------------------------
# Form
# -----------------------------
$form = New-Object Windows.Forms.Form
$form.Text = 'Create Azure VM'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object Drawing.Size(700, 810)
$form.MaximizeBox = $false

# -----------------------------
# Azure Server Info Group
# -----------------------------
$azureInfoGroupBox = New-Object Windows.Forms.GroupBox
$azureInfoGroupBox.Text = "Azure Server Information"
$azureInfoGroupBox.Location = New-Object Drawing.Point(5, 50)
$azureInfoGroupBox.Size = New-Object Drawing.Size(670, 350)
$form.Controls.Add($azureInfoGroupBox)

# -----------------------------
# Left column labels/inputs
# -----------------------------
$vmNameLabel = New-Object Windows.Forms.Label
$vmNameLabel.Text = "VM Name*:"
$vmNameLabel.Location = New-Object Drawing.Point(10, 60)
$vmNameLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vmNameLabel)

$vmNameTextBox = New-Object Windows.Forms.TextBox
$vmNameTextBox.Location = New-Object Drawing.Point(120, 60)
$vmNameTextBox.Size = New-Object Drawing.Size(200, 30)
$form.Controls.Add($vmNameTextBox)

$rgLabel = New-Object Windows.Forms.Label
$rgLabel.Text = "Resource Group*:"
$rgLabel.Location = New-Object Drawing.Point(10, 100)
$rgLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($rgLabel)

$rgComboBox = New-Object Windows.Forms.ComboBox
$rgComboBox.Location = New-Object Drawing.Point(120, 100)
$rgComboBox.Size = New-Object Drawing.Size(200, 30)
$rgComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($rgComboBox)

$vnetRGLabel = New-Object Windows.Forms.Label
$vnetRGLabel.Text = "VNet Resource*:"
$vnetRGLabel.Location = New-Object Drawing.Point(10, 140)
$vnetRGLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vnetRGLabel)

$vnetRGComboBox = New-Object Windows.Forms.ComboBox
$vnetRGComboBox.Location = New-Object Drawing.Point(120, 140)
$vnetRGComboBox.Size = New-Object Drawing.Size(200, 30)
$vnetRGComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($vnetRGComboBox)

$vnetLabel = New-Object Windows.Forms.Label
$vnetLabel.Text = "VNet Name*:"
$vnetLabel.Location = New-Object Drawing.Point(10, 180)
$vnetLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vnetLabel)

$vnetComboBox = New-Object Windows.Forms.ComboBox
$vnetComboBox.Location = New-Object Drawing.Point(120, 180)
$vnetComboBox.Size = New-Object Drawing.Size(200, 30)
$vnetComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($vnetComboBox)

$snetLabel = New-Object Windows.Forms.Label
$snetLabel.Text = "Subnet Name*:"
$snetLabel.Location = New-Object Drawing.Point(10, 220)
$snetLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($snetLabel)

$snetComboBox = New-Object Windows.Forms.ComboBox
$snetComboBox.Location = New-Object Drawing.Point(120, 220)
$snetComboBox.Size = New-Object Drawing.Size(200, 30)
$snetComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($snetComboBox)

$snetNSGLabel = New-Object Windows.Forms.Label
$snetNSGLabel.Text = "NSG:"
$snetNSGLabel.Location = New-Object Drawing.Point(10, 260)
$snetNSGLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($snetNSGLabel)

$snetNSGComboBox = New-Object Windows.Forms.ComboBox
$snetNSGComboBox.Location = New-Object Drawing.Point(120, 260)
$snetNSGComboBox.Size = New-Object Drawing.Size(200, 30)
$snetNSGComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($snetNSGComboBox)

$storageLabel = New-Object Windows.Forms.Label
$storageLabel.Text = "Storage Group*:"
$storageLabel.Location = New-Object Drawing.Point(10, 300)
$storageLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($storageLabel)

$storageComboBox = New-Object Windows.Forms.ComboBox
$storageComboBox.Location = New-Object Drawing.Point(120, 300)
$storageComboBox.Size = New-Object Drawing.Size(200, 30)
$storageComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($storageComboBox)

# -----------------------------
# Right column labels/inputs
# -----------------------------
$ipLabelRight = New-Object Windows.Forms.Label
$ipLabelRight.Text = "IP Address*:"
$ipLabelRight.Location = New-Object Drawing.Point(330, 60)
$ipLabelRight.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($ipLabelRight)

$ipTextBoxRight = New-Object Windows.Forms.TextBox
$ipTextBoxRight.Location = New-Object Drawing.Point(440, 60)
$ipTextBoxRight.Size = New-Object Drawing.Size(200, 30)
$form.Controls.Add($ipTextBoxRight)

$vmSizeLabelRight = New-Object Windows.Forms.Label
$vmSizeLabelRight.Text = "VM Size*:"
$vmSizeLabelRight.Location = New-Object Drawing.Point(330, 100)
$vmSizeLabelRight.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vmSizeLabelRight)

$vmSizeComboBoxRight = New-Object Windows.Forms.ComboBox
$vmSizeComboBoxRight.Location = New-Object Drawing.Point(440, 100)
$vmSizeComboBoxRight.Size = New-Object Drawing.Size(200, 30)
$vmSizeComboBoxRight.DropDownStyle = 'DropDownList'
$form.Controls.Add($vmSizeComboBoxRight)

$vmSizes = @(
    'Standard_DS1_v2','Standard_DS2_v2','Standard_DS3_v2','Standard_DS4_v2',
    'Standard_D1_v2','Standard_D2_v2','Standard_D3_v2','Standard_D4_v2','Standard_D5_v2',
    'Standard_F1'
)
foreach ($vmSize in $vmSizes) { [void]$vmSizeComboBoxRight.Items.Add($vmSize) }

$storageTypeLabelRight = New-Object Windows.Forms.Label
$storageTypeLabelRight.Text = "Disk Type*:"
$storageTypeLabelRight.Location = New-Object Drawing.Point(330, 140)
$storageTypeLabelRight.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($storageTypeLabelRight)

$storageTypeComboBoxRight = New-Object Windows.Forms.ComboBox
$storageTypeComboBoxRight.Location = New-Object Drawing.Point(440, 140)
$storageTypeComboBoxRight.Size = New-Object Drawing.Size(200, 30)
$storageTypeComboBoxRight.DropDownStyle = 'DropDownList'
$form.Controls.Add($storageTypeComboBoxRight)

$storageTypes = @(
    'Premium_LRS','Premium_ZRS','Standard_GRS','Standard_GZRS',
    'Standard_LRS','Standard_RAGRS','Standard_RAGZRS','Standard_ZRS','StandardSSD_LRS'
)
foreach ($storageType in $storageTypes) { [void]$storageTypeComboBoxRight.Items.Add($storageType) }

$osLabelRight = New-Object Windows.Forms.Label
$osLabelRight.Text = "OS Spec*:"
$osLabelRight.Location = New-Object Drawing.Point(330, 180)
$osLabelRight.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($osLabelRight)

$osComboBoxRight = New-Object Windows.Forms.ComboBox
$osComboBoxRight.Location = New-Object Drawing.Point(440, 180)
$osComboBoxRight.Size = New-Object Drawing.Size(200, 30)
$osComboBoxRight.DropDownStyle = 'DropDownList'
$form.Controls.Add($osComboBoxRight)

$osList = @(
    'Server2016','Server2019','Server2022',
    'Ubuntu1804','Ubuntu2004','Ubuntu2204',
    'Debian11','CentOS7','CentOS8','RHEL8','RHEL9',
    'SLES12','SLES15','AlmaLinux8','OracleLinux7','OracleLinux8','FlatcarContainerLinux',
    'WindowsServerCore2016','WindowsServerCore2019','WindowsServerCore2022'
)
foreach ($os in $osList) { [void]$osComboBoxRight.Items.Add($os) }

$locationLabelRight = New-Object Windows.Forms.Label
$locationLabelRight.Text = "Location*:"
$locationLabelRight.Location = New-Object Drawing.Point(330, 220)
$locationLabelRight.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($locationLabelRight)

$locationComboBoxRight = New-Object Windows.Forms.ComboBox
$locationComboBoxRight.Location = New-Object Drawing.Point(440, 220)
$locationComboBoxRight.Size = New-Object Drawing.Size(200, 30)
$locationComboBoxRight.DropDownStyle = 'DropDownList'
$form.Controls.Add($locationComboBoxRight)

$locationList = @('eastus','eastus2','westus','westus2')
foreach ($location in $locationList) { [void]$locationComboBoxRight.Items.Add($location) }

# -----------------------------
# Move controls into group
# -----------------------------
$azureInfoGroupBox.Controls.Add($vmNameLabel)
$azureInfoGroupBox.Controls.Add($vmNameTextBox)
$azureInfoGroupBox.Controls.Add($rgLabel)
$azureInfoGroupBox.Controls.Add($rgComboBox)
$azureInfoGroupBox.Controls.Add($vnetRGLabel)
$azureInfoGroupBox.Controls.Add($vnetRGComboBox)
$azureInfoGroupBox.Controls.Add($vnetLabel)
$azureInfoGroupBox.Controls.Add($vnetComboBox)
$azureInfoGroupBox.Controls.Add($snetLabel)
$azureInfoGroupBox.Controls.Add($snetComboBox)
$azureInfoGroupBox.Controls.Add($snetNSGLabel)
$azureInfoGroupBox.Controls.Add($snetNSGComboBox)
$azureInfoGroupBox.Controls.Add($storageLabel)
$azureInfoGroupBox.Controls.Add($storageComboBox)
$azureInfoGroupBox.Controls.Add($ipLabelRight)
$azureInfoGroupBox.Controls.Add($ipTextBoxRight)
$azureInfoGroupBox.Controls.Add($vmSizeLabelRight)
$azureInfoGroupBox.Controls.Add($vmSizeComboBoxRight)
$azureInfoGroupBox.Controls.Add($storageTypeLabelRight)
$azureInfoGroupBox.Controls.Add($storageTypeComboBoxRight)
$azureInfoGroupBox.Controls.Add($osLabelRight)
$azureInfoGroupBox.Controls.Add($osComboBoxRight)
$azureInfoGroupBox.Controls.Add($locationLabelRight)
$azureInfoGroupBox.Controls.Add($locationComboBoxRight)

# -----------------------------
# Bicep Param File picker (for Deploy Now path)
# -----------------------------
$bicepFileLabel = New-Object Windows.Forms.Label
$bicepFileLabel.Text = "Bicep Param File*:"
$bicepFileLabel.Location = New-Object Drawing.Point(10, 420)
$form.Controls.Add($bicepFileLabel)

$bicepFilePathTextBox = New-Object Windows.Forms.TextBox
$bicepFilePathTextBox.Location = New-Object Drawing.Point(120, 420)
$bicepFilePathTextBox.Size = New-Object Drawing.Size(350, 30)
$bicepFilePathTextBox.ReadOnly = $true
$form.Controls.Add($bicepFilePathTextBox)

$fileBrowseButton = New-Object Windows.Forms.Button
$fileBrowseButton.Text = "Browse"
$fileBrowseButton.Location = New-Object Drawing.Point(480, 415)
$fileBrowseButton.Size = New-Object Drawing.Size(80, 30)
$fileBrowseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Bicep Parameter Files (*.bicepparam)|*.bicepparam|All Files (*.*)|*.*"
    $openFileDialog.Title = "Select main.bicepparam file"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $bicepFilePathTextBox.Text = $openFileDialog.FileName
    }
})
$form.Controls.Add($fileBrowseButton)

# -----------------------------
# Active Directory OU chooser
# -----------------------------
$ouLabel = New-Object Windows.Forms.Label
$ouLabel.Text = "OU*:"
$ouLabel.Location = New-Object Drawing.Point(10, 450)
$ouLabel.Size = New-Object Drawing.Size(30, 30)
$form.Controls.Add($ouLabel)

$selectedOUTextBox = New-Object Windows.Forms.TextBox
$selectedOUTextBox.Location = New-Object Drawing.Point(120, 450)
$selectedOUTextBox.Size = New-Object Drawing.Size(350, 30)
$selectedOUTextBox.ReadOnly = $true
$form.Controls.Add($selectedOUTextBox)

$adTreeView = New-Object Windows.Forms.TreeView
$adTreeView.Location = New-Object Drawing.Point(10, 490)
$adTreeView.Size = New-Object Drawing.Size(250, 150)
$form.Controls.Add($adTreeView)

# -----------------------------
# Tags/Metadata pickers (Env/Dept/Owner/App)
# -----------------------------
$labelEnv = New-Object Windows.Forms.Label
$labelEnv.Text = "Environment:"
$labelEnv.Location = New-Object Drawing.Point(280, 490)
$labelEnv.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($labelEnv)

$comboBoxEnv = New-Object Windows.Forms.ComboBox
$comboBoxEnv.Location = New-Object Drawing.Point(380, 490)
$comboBoxEnv.Size = New-Object Drawing.Size(200, 30)
$comboBoxEnv.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboBoxEnv)
@('prod','dev','test') | ForEach-Object { [void]$comboBoxEnv.Items.Add($_) }

$labelDept = New-Object Windows.Forms.Label
$labelDept.Text = "Business Unit:"
$labelDept.Location = New-Object Drawing.Point(280, 530)
$labelDept.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($labelDept)

$comboBoxDept = New-Object Windows.Forms.ComboBox
$comboBoxDept.Location = New-Object Drawing.Point(380, 530)
$comboBoxDept.Size = New-Object Drawing.Size(200, 30)
$comboBoxDept.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboBoxDept)
@('IT','HR','Finance') | ForEach-Object { [void]$comboBoxDept.Items.Add($_) }

$labelOwner = New-Object Windows.Forms.Label
$labelOwner.Text = "Owner:"
$labelOwner.Location = New-Object Drawing.Point(280, 570)
$labelOwner.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($labelOwner)

$comboBoxOwner = New-Object Windows.Forms.ComboBox
$comboBoxOwner.Location = New-Object Drawing.Point(380, 570)
$comboBoxOwner.Size = New-Object Drawing.Size(200, 30)
$comboBoxOwner.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboBoxOwner)
@('Server Team','Application Team','Web Team') | ForEach-Object { [void]$comboBoxOwner.Items.Add($_) }

$labelApp = New-Object Windows.Forms.Label
$labelApp.Text = "Application:"
$labelApp.Location = New-Object Drawing.Point(280, 610)
$labelApp.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($labelApp)

$comboBoxApp = New-Object Windows.Forms.ComboBox
$comboBoxApp.Location = New-Object Drawing.Point(380, 610)
$comboBoxApp.Size = New-Object Drawing.Size(200, 30)
$comboBoxApp.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboBoxApp)
@('VS Code','Net App','CommVault') | ForEach-Object { [void]$comboBoxApp.Items.Add($_) }

# -----------------------------
# Azure Login / Populate controls
# -----------------------------
$connectButton = New-Object Windows.Forms.Button
$connectButton.Text = "Connect to Azure"
$connectButton.Location = New-Object Drawing.Point(50, 10)
$connectButton.Size = New-Object Drawing.Size(600, 30)
$connectButton.Add_Click({
    try {
        $account = az account show 2>$null
        if (-not $account) {
            az login 2>$null | Out-Null
            $account = az account show 2>$null
            if (-not $account) {
                $tenantId = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your Azure Tenant ID:", "Tenant Required", "")
                if (![string]::IsNullOrWhiteSpace($tenantId)) {
                    az login --tenant $tenantId 2>$null | Out-Null
                    $account = az account show 2>$null
                }
            }
        }

        if ($account) {
            Show-Info "Connected to Azure."

            # RGs
            $rgList = az group list --query "[].name" -o tsv
            $rgComboBox.Items.Clear()
            $vnetRGComboBox.Items.Clear()

            $rgList | ForEach-Object {
                [void]$rgComboBox.Items.Add($_)
                [void]$vnetRGComboBox.Items.Add($_)
            }

            if ($rgComboBox.Items.Count -gt 0) { $rgComboBox.SelectedIndex = 0 }
            if ($vnetRGComboBox.Items.Count -gt 0) { $vnetRGComboBox.SelectedIndex = 0 }
        } else {
            Show-Error "Azure login failed. No tenant found."
        }
    } catch {
        Show-Error "Azure login error: $_"
    }
})
$form.Controls.Add($connectButton)

# When VNet RG changes, populate VNet, Subnets, NSGs, Storage
$vnetRGComboBox.add_SelectedIndexChanged({
    $selectedResourceGroup = $vnetRGComboBox.SelectedItem
    if (-not $selectedResourceGroup) { return }

    try {
        # VNets
        $vnetList = az network vnet list --resource-group $selectedResourceGroup --query "[].name" -o tsv
        $vnetComboBox.Items.Clear()
        $vnetList | ForEach-Object { [void]$vnetComboBox.Items.Add($_) }
        if ($vnetComboBox.Items.Count -gt 0) { $vnetComboBox.SelectedIndex = 0 } else { Show-Warn "No VNets in RG '$selectedResourceGroup'." }

        # Subnets (for first VNet initially)
        if ($vnetComboBox.SelectedItem) {
            $selectedVnet = $vnetComboBox.SelectedItem
            $subnetList = az network vnet subnet list --resource-group $selectedResourceGroup --vnet-name $selectedVnet --query "[].name" -o tsv
            $snetComboBox.Items.Clear()
            $subnetList | ForEach-Object { [void]$snetComboBox.Items.Add($_) }
            if ($snetComboBox.Items.Count -gt 0) { $snetComboBox.SelectedIndex = 0 } else { Show-Warn "No subnets in VNet '$selectedVnet'." }
        }

        # NSGs in that RG (list)
        $subnetNSGList = az network nsg list --resource-group $selectedResourceGroup --query "[].name" -o tsv
        $snetNSGComboBox.Items.Clear()
        if ($subnetNSGList) {
            $subnetNSGList | ForEach-Object { [void]$snetNSGComboBox.Items.Add($_) }
            $snetNSGComboBox.Items.Add("No NSG") | Out-Null
            $snetNSGComboBox.SelectedIndex = 0
        } else {
            $snetNSGComboBox.Items.Add("No NSG") | Out-Null
            $snetNSGComboBox.SelectedIndex = 0
        }

        # Storage accounts (NOTE: this uses selectedResourceGroup == VNet RG; adjust if you want different RG)
        $storageList = az storage account list --resource-group $selectedResourceGroup --query "[].name" -o tsv
        $storageComboBox.Items.Clear()
        $storageList | ForEach-Object { [void]$storageComboBox.Items.Add($_) }
        if ($storageComboBox.Items.Count -gt 0) { $storageComboBox.SelectedIndex = 0 } else { Show-Warn "No storage accounts in RG '$selectedResourceGroup'." }

    } catch {
        Show-Error "Error fetching resources: $_"
    }
})

# If VNet changes after selection, refresh subnets
$vnetComboBox.add_SelectedIndexChanged({
    $rg = $vnetRGComboBox.SelectedItem
    $vnet = $vnetComboBox.SelectedItem
    if ($rg -and $vnet) {
        try {
            $subnetList = az network vnet subnet list --resource-group $rg --vnet-name $vnet --query "[].name" -o tsv
            $snetComboBox.Items.Clear()
            $subnetList | ForEach-Object { [void]$snetComboBox.Items.Add($_) }
            if ($snetComboBox.Items.Count -gt 0) { $snetComboBox.SelectedIndex = 0 } else { Show-Warn "No subnets in VNet '$vnet'." }
        } catch {
            Show-Error "Error fetching subnets: $_"
        }
    }
})

# -----------------------------
# AD OU Loading
# -----------------------------
function Load-OUs {
    param([string]$baseDN = 'DC=SkyN3t,DC=local')
    try {
        $searcher = New-Object DirectoryServices.DirectorySearcher
        $searcher.SearchRoot = New-Object DirectoryServices.DirectoryEntry("LDAP://$baseDN")
        $searcher.Filter = "(objectClass=organizationalUnit)"
        $searcher.SearchScope = [System.DirectoryServices.SearchScope]::OneLevel

        $adTreeView.Nodes.Clear()
        $searcher.FindAll() | ForEach-Object {
            $entry = $_.GetDirectoryEntry()
            $node = New-Object Windows.Forms.TreeNode
            $node.Text = $entry.Properties["name"][0]
            $node.Tag  = $entry.Properties["distinguishedName"][0]
            $node.Nodes.Add("Loading...") | Out-Null
            [void]$adTreeView.Nodes.Add($node)
        }
    } catch {
        Show-Error "Error loading Active Directory: $_"
    }
}

$adTreeView.add_BeforeExpand({
    $node = $_.Node
    if ($node.Nodes.Count -gt 0 -and $node.Nodes[0].Text -eq "Loading...") {
        $node.Nodes.Clear()
        $searcher = New-Object DirectoryServices.DirectorySearcher
        $searcher.SearchRoot = New-Object DirectoryServices.DirectoryEntry("LDAP://$($node.Tag)")
        $searcher.Filter = "(objectClass=organizationalUnit)"
        $searcher.SearchScope = [System.DirectoryServices.SearchScope]::OneLevel

        $searcher.FindAll() | ForEach-Object {
            $entry = $_.GetDirectoryEntry()
            $childNode = New-Object Windows.Forms.TreeNode
            $childNode.Text = $entry.Properties["name"][0]
            $childNode.Tag  = $entry.Properties["distinguishedName"][0]
            $childNode.Nodes.Add("Loading...") | Out-Null
            [void]$node.Nodes.Add($childNode)
        }
    }
})

$adTreeView.add_NodeMouseClick({
    $selectedNode = $_.Node
    $selectedOUTextBox.Text = $selectedNode.Tag
})

# -----------------------------
# Git / Commit Section
# -----------------------------
$gitGroup = New-Object Windows.Forms.GroupBox
$gitGroup.Text = "Git (Optional)"
$gitGroup.Location = New-Object Drawing.Point(5, 645)
$gitGroup.Size = New-Object Drawing.Size(670, 80)
$form.Controls.Add($gitGroup)

$chkCommitOnly = New-Object Windows.Forms.CheckBox
$chkCommitOnly.Text = "Generate main.bicepparam and Push to Git (no deploy)"
$chkCommitOnly.Location = New-Object Drawing.Point(10, 20)
$chkCommitOnly.Size = New-Object Drawing.Size(350, 25)
$gitGroup.Controls.Add($chkCommitOnly)

$lblRepo = New-Object Windows.Forms.Label
$lblRepo.Text = "Repo:"
$lblRepo.Location = New-Object Drawing.Point(10, 50)
$lblRepo.Size = New-Object Drawing.Size(40, 20)
$gitGroup.Controls.Add($lblRepo)

$txtRepo = New-Object Windows.Forms.TextBox
$txtRepo.Location = New-Object Drawing.Point(50, 47)
$txtRepo.Size = New-Object Drawing.Size(290, 24)
$gitGroup.Controls.Add($txtRepo)

$btnRepoBrowse = New-Object Windows.Forms.Button
$btnRepoBrowse.Text = "Browse"
$btnRepoBrowse.Location = New-Object Drawing.Point(345, 46)
$btnRepoBrowse.Size = New-Object Drawing.Size(60, 24)
$gitGroup.Controls.Add($btnRepoBrowse)

$folderDlg = New-Object System.Windows.Forms.FolderBrowserDialog
$btnRepoBrowse.Add_Click({
    if ($folderDlg.ShowDialog() -eq "OK") { $txtRepo.Text = $folderDlg.SelectedPath }
})

$lblBranch = New-Object Windows.Forms.Label
$lblBranch.Text = "Branch:"
$lblBranch.Location = New-Object Drawing.Point(415, 50)
$lblBranch.Size = New-Object Drawing.Size(50, 20)
$gitGroup.Controls.Add($lblBranch)

$txtBranch = New-Object Windows.Forms.TextBox
$txtBranch.Location = New-Object Drawing.Point(470, 47)
$txtBranch.Size = New-Object Drawing.Size(80, 24)
$txtBranch.Text = "dev"
$gitGroup.Controls.Add($txtBranch)

$lblCommit = New-Object Windows.Forms.Label
$lblCommit.Text = "Msg:"
$lblCommit.Location = New-Object Drawing.Point(560, 50)
$lblCommit.Size = New-Object Drawing.Size(35, 20)
$gitGroup.Controls.Add($lblCommit)

$txtCommit = New-Object Windows.Forms.TextBox
$txtCommit.Location = New-Object Drawing.Point(595, 47)
$txtCommit.Size = New-Object Drawing.Size(65, 24)
$txtCommit.Text = "Auto: VM params"
$gitGroup.Controls.Add($txtCommit)

# Toggle param-file UI enable/disable based on commit mode
$chkCommitOnly.Add_CheckedChanged({
    $commit = $chkCommitOnly.Checked
    $bicepFilePathTextBox.Enabled = -not $commit
    $fileBrowseButton.Enabled     = -not $commit
    $txtRepo.Enabled              = $commit
    $btnRepoBrowse.Enabled        = $commit
    $txtBranch.Enabled            = $commit
    $txtCommit.Enabled            = $commit
})

# Set initial UI state (unchecked = Deploy Now mode)
$chkCommitOnly.Checked = $false
$bicepFilePathTextBox.Enabled = $true
$fileBrowseButton.Enabled     = $true
$txtRepo.Enabled              = $false
$btnRepoBrowse.Enabled        = $false
$txtBranch.Enabled            = $false
$txtCommit.Enabled            = $false

# -----------------------------
# Submit (Deploy or Commit)
# -----------------------------
$submitButton = New-Object Windows.Forms.Button
$submitButton.Text = "Create VM  /  Generate & Push"
$submitButton.Location = New-Object Drawing.Point(30, 730)
$submitButton.Size = New-Object Drawing.Size(640, 30)
$submitButton.Add_Click({
    $vmName            = $vmNameTextBox.Text
    $resourceGroup     = $rgComboBox.SelectedItem
    $vnetName          = $vnetComboBox.SelectedItem
    $vNetResourceGroup = $vnetRGComboBox.SelectedItem
    $storageAccount    = $storageComboBox.SelectedItem
    $snet              = $snetComboBox.SelectedItem
    $nsg               = $snetNSGComboBox.SelectedItem
    $vmSize            = $vmSizeComboBoxRight.SelectedItem
    $storageType       = $storageTypeComboBoxRight.SelectedItem
    $os                = $osComboBoxRight.SelectedItem
    $ip                = $ipTextBoxRight.Text
    $env               = $comboBoxEnv.SelectedItem
    $owner             = $comboBoxOwner.SelectedItem
    $dept              = $comboBoxDept.SelectedItem
    $app               = $comboBoxApp.SelectedItem
    $selectedOU        = $selectedOUTextBox.Text
    $bicepParamFile    = $bicepFilePathTextBox.Text
    $location          = $locationComboBoxRight.SelectedItem

    $commitOnly        = $chkCommitOnly.Checked
    $repoPath          = $txtRepo.Text
    $branch            = $txtBranch.Text
    $commitMsg         = $txtCommit.Text

    if ([string]::IsNullOrWhiteSpace($vmName) -or
        [string]::IsNullOrWhiteSpace($resourceGroup) -or
        [string]::IsNullOrWhiteSpace($vnetName) -or
        [string]::IsNullOrWhiteSpace($storageAccount) -or
        [string]::IsNullOrWhiteSpace($selectedOU) -or
        [string]::IsNullOrWhiteSpace($location)) {
        Show-Warn 'Please fill in all required fields!'
        return
    }

    try {
        if ($commitOnly) {
            if ([string]::IsNullOrWhiteSpace($repoPath) -or -not (Test-Path $repoPath)) {
                Show-Warn "Please select a valid Git repository path."
                return
            }
            $gitFolder = Join-Path $repoPath ".git"
            if (-not (Test-Path $gitFolder)) {
                Show-Warn "Selected folder is not a Git repo (missing .git)."
                return
            }

            # Relative path inside repo and absolute path to write
            $paramRelPath = Join-Path "infrastructure-as-a-code-sandbox" "bicep\templates\create-virtual-machine\main.bicepparam"
            $paramPath    = Join-Path $repoPath $paramRelPath

            # Ensure directory exists
            $null = New-Item -ItemType Directory -Path (Split-Path $paramPath) -Force

            # Build .bicepparam content (closing "@ must be at column 1)\

# Make sure you're logged in to the right tenant/sub first
$subId = (az account show --query id -o tsv).Trim()

$paramContent = @"
using 'main.bicep'

// --- Fixed values (safe to commit) ---
param domainFQDN           = 'SkyN3t.local'
param kvname               = 'kv-skynet'
param domainJoinUserName   = 'AzureServiceAccount'
param domainJoinSecretName = 'domainJoinSAPassSecret'
param vmUserName           = 'SkynetAdmin'
param vmSecretName         = 'vmPasswordSecret'

// --- Secure values from Key Vault ---
param vmPassword             = az.getSecret('$subId', '$(Escape-SingleQuotes $resourceGroup)', kvname, vmSecretName)
param domainJoinUserPassword = az.getSecret('$subId', '$(Escape-SingleQuotes $resourceGroup)', kvname, domainJoinSecretName)

// --- UI-driven values ---
param vmName              = '$(Escape-SingleQuotes $vmName)'
param vnetName            = '$(Escape-SingleQuotes $vnetName)'
param vNetResourceGroup   = '$(Escape-SingleQuotes $vNetResourceGroup)'
param subnetName          = '$(Escape-SingleQuotes $snet)'
param NSG                 = '$(Escape-SingleQuotes $nsg)'
param storageAccountName  = '$(Escape-SingleQuotes $storageAccount)'
param vmSize              = '$(Escape-SingleQuotes $vmSize)'
param storageAccountType  = '$(Escape-SingleQuotes $storageType)'
param OS                  = '$(Escape-SingleQuotes $os)'
param location            = '$(Escape-SingleQuotes $location)'
param IP                  = '$(Escape-SingleQuotes $ip)'
param dept                = '$(Escape-SingleQuotes $dept)'
param env                 = '$(Escape-SingleQuotes $env)'
param app                 = '$(Escape-SingleQuotes $app)'
param owner               = '$(Escape-SingleQuotes $owner)'
param ouPath              = '$(Escape-SingleQuotes $selectedOU)'
param resourceGroupName   = '$(Escape-SingleQuotes $resourceGroup)'
param sshPublicKey        = ''
"@



            # Write file
            Set-Content -Path $paramPath -Value $paramContent -Force -Encoding UTF8

            Push-Location $repoPath
            try {
                # checkout branch (create if missing)
                git rev-parse --verify $branch 2>$null | Out-Null
                if ($LASTEXITCODE -ne 0) { git checkout -b $branch } else { git checkout $branch }

                # Stage the correct file (relative to repo root)
                git add -- $paramRelPath

                # Commit only if there is an actual change
                $changed = git status --porcelain -- $paramRelPath
                if ([string]::IsNullOrWhiteSpace($changed)) {
                    [System.Windows.Forms.MessageBox]::Show("No changes in $paramRelPath - nothing to commit.", "Info") | Out-Null
                } else {
                    if ([string]::IsNullOrWhiteSpace($commitMsg)) { $commitMsg = "Auto: VM params" }
                    git commit -m $commitMsg
                    git push origin $branch
                    [System.Windows.Forms.MessageBox]::Show("Committed and pushed $paramRelPath to '$branch'.", "Info") | Out-Null

                    # Close the form after successful commit/push
                    $form.Close()
                    
                }
            }
            finally {
                Pop-Location
            }

            return
        }
        else {
            if ([string]::IsNullOrWhiteSpace($bicepParamFile) -or -not (Test-Path $bicepParamFile)) {
                Show-Warn "Select a valid .bicepparam file (or use the Git option)."
                return
            }

            $bicepCommand = @"
az deployment group create `
  --resource-group $resourceGroup `
  --template-file ./main.bicep `
  --parameters @$bicepParamFile `
  vmName='$vmName' `
  vnetName='$vnetName' `
  vNetResourceGroup='$vNetResourceGroup' `
  subnetName='$snet' `
  NSG='$nsg' `
  storageAccountName='$storageAccount' `
  vmSize='$vmSize' `
  storageAccountType='$storageType' `
  OS='$os' `
  location='$location' `
  IP='$ip' `
  dept='$dept' `
  env='$env' `
  app='$app' `
  owner='$owner' `
  ouPath='$selectedOU'
"@

            Invoke-Expression $bicepCommand
            Show-Info 'VM Creation Successful!'
        }
    }
    catch {
        Show-Error ("Error: " + $_)
    }
})
$form.Controls.Add($submitButton)


# -----------------------------
# Load OUs at start
# -----------------------------
Load-OUs | Out-Null

# -----------------------------
# Show UI
# -----------------------------
[void]$form.ShowDialog()
