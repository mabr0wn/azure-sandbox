<#
.SYNOPSIS
  Used to created VM servers in Azure.
.DESCRIPTION
  Uses a combination of Active Directory, Bicep, and Powershell commands to create a Virtual Server in Azure.
.NOTES
  Version:        3.96
  Author:         Matt Brown
  Creation Date:  10/8/2024
  Change Date: 1/1/2025
  Purpose/Change: Updated vnet to have it own seperate rg in case your vnet is not in same rg as your vms.
  Changed By: Matt Brown
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object Windows.Forms.Form
$form.Text = 'Create Azure VM'
$form.Size = New-Object Drawing.Size(675, 730)

# Create a GroupBox for Azure Server Information
$azureInfoGroupBox = New-Object Windows.Forms.GroupBox
$azureInfoGroupBox.Text = "Azure Server Information"
$azureInfoGroupBox.Location = New-Object Drawing.Point(5, 50) # Adjust position as needed
$azureInfoGroupBox.Size = New-Object Drawing.Size(650, 350)  # Adjust size as needed
$form.Controls.Add($azureInfoGroupBox)

# VM Name Section (Left)
$vmNameLabel = New-Object Windows.Forms.Label
$vmNameLabel.Text = "VM Name*:"
$vmNameLabel.Location = New-Object Drawing.Point(10, 60)
$vmNameLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vmNameLabel)

$vmNameTextBox = New-Object Windows.Forms.TextBox
$vmNameTextBox.Location = New-Object Drawing.Point(120, 60)
$vmNameTextBox.Size = New-Object Drawing.Size(200, 30)
$form.Controls.Add($vmNameTextBox)

# VM count Section (Left)
# $countLabel = New-Object Windows.Forms.Label
# $countLabel.Text = "Count:"
# $countLabel.Location = New-Object Drawing.Point(230, 60)
# $countLabel.Size = New-Object Drawing.Size(40, 20)
# $form.Controls.Add($countLabel)

# $countComboBox = New-Object Windows.Forms.ComboBox
# $countComboBox.Location = New-Object Drawing.Point(270, 60)
# $countComboBox.Size = New-Object Drawing.Size(50, 30)
# $countComboBox.DropDownStyle = 'DropDownList'
# $form.Controls.Add($countComboBox)

# $countSizes = @(
#     '1', '2', '3', '4',
#     '5', '6', '7', '8',
#     '9', '10'
# )

# foreach ($countSize in $countSizes) {
#     $countComboBox.Items.Add($countSize) > $null
# }

# Resource Group Section (Left)
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

# VNet Resource Group Section (Left)
$vnetRGLabel = New-Object Windows.Forms.Label
$vnetRGLabel.Text = "Vnet Resource*:"
$vnetRGLabel.Location = New-Object Drawing.Point(10, 140)
$vnetRGLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vnetRGLabel)

$vnetRGComboBox = New-Object Windows.Forms.ComboBox
$vnetRGComboBox.Location = New-Object Drawing.Point(120, 140)
$vnetRGComboBox.Size = New-Object Drawing.Size(200, 30)
$vnetRGComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($vnetRGComboBox)

# VNet Section (Left)
$vnetLabel = New-Object Windows.Forms.Label
$vnetLabel.Text = "Vnet Name*:"
$vnetLabel.Location = New-Object Drawing.Point(10, 180)
$vnetLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vnetLabel)

$vnetComboBox = New-Object Windows.Forms.ComboBox
$vnetComboBox.Location = New-Object Drawing.Point(120, 180)
$vnetComboBox.Size = New-Object Drawing.Size(200, 30)
$vnetComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($vnetComboBox)

# Subnet Section (Left)
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

# Subnet NSG Section (Left)
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

# Storage Account Section (Left)
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

# Adding 5 more boxes to the right side (shift the X position to the right)

# IP Label Section (Right)
$ipLabelRight = New-Object Windows.Forms.Label
$ipLabelRight.Text = "IP Address*:"
$ipLabelRight.Location = New-Object Drawing.Point(330, 60)
$ipLabelRight.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($ipLabelRight)

# IP Textbox Section (Right)
$ipTextBoxRight = New-Object Windows.Forms.TextBox
$ipTextBoxRight.Location = New-Object Drawing.Point(440, 60)
$ipTextBoxRight.Size = New-Object Drawing.Size(200, 30)

$form.Controls.Add($ipTextBoxRight)


# VM Size Section (Right)
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
    'Standard_DS1_v2', 'Standard_DS2_v2', 'Standard_DS3_v2', 'Standard_DS4_v2',
    'Standard_D1_v2', 'Standard_D2_v2', 'Standard_D3_v2', 'Standard_D4_v2',
    'Standard_D5_v2', 'Standard_F1'
)

foreach ($vmSize in $vmSizes) {
    $vmSizeComboBoxRight.Items.Add($vmSize) > $null
}


# VNet Section (Right)
$storageTypeLabelRight = New-Object Windows.Forms.Label
$storageTypeLabelRight.Text = "Disk Type*:"
$storageTypeLabelRight.Location = New-Object Drawing.Point(330, 140)
$storageTypeLabelRight.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($storageTypeLabelRight)

$storageTypeComboBoxRight = New-Object Windows.Forms.ComboBox
$storageTypeComboBoxRight.Location = New-Object Drawing.Point(440, 140)
$storageTypeComboBoxRight.Size = New-Object Drawing.Size(200, 30)
$storageTypeComboBoxRight.DropDownStyle = 'DropDownList'

# Add disk type options to the ComboBox
$storageTypes = @(
    'Premium_LRS', 'Premium_ZRS', 'Standard_GRS', 'Standard_GZRS', 
    'Standard_LRS', 'Standard_RAGRS', 'Standard_RAGZRS', 'Standard_ZRS', 
    'StandardSSD_LRS'
)

foreach ($storageType in $storageTypes) {
    $storageTypeComboBoxRight.Items.Add($storageType) > $null
}


$form.Controls.Add($storageTypeComboBoxRight)

# Subnet Section (Right)
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

# Add OS options to the ComboBox
$osList = @(
    'Server2016', 'Server2019', 'Server2022',
    'Ubuntu1804', 'Ubuntu2004', 'Ubuntu2204',
    'Debian11', 'CentOS7', 'CentOS8', 'RHEL8', 'RHEL9',
    'SLES12', 'SLES15', 'AlmaLinux8', 'OracleLinux7',
    'OracleLinux8', 'FlatcarContainerLinux',
    'WindowsServerCore2016', 'WindowsServerCore2019',
    'WindowsServerCore2022'
)

foreach ($os in $osList) {
    $osComboBoxRight.Items.Add($os) > $null
}

 # Location Section (Right)
 $locationLabelRight = New-Object Windows.Forms.Label
 $locationlabelRight.Text = "Location*:"
 $locationlabelRight.Location = New-Object Drawing.Point(330, 220)
 $locationlabelRight.Size = New-Object Drawing.Size(100, 30)
 $form.Controls.Add($locationLabelRight)
 
 $locationComboBoxRight = New-Object Windows.Forms.ComboBox
 $locationComboBoxRight.Location = New-Object Drawing.Point(440, 220)
 $locationComboBoxRight.Size = New-Object Drawing.Size(200, 30)
 $locationComboBoxRight.DropDownStyle = 'DropDownList'
 $form.Controls.Add($locationComboBoxRight)
 
 # Add location options to the ComboBox
 $locationList = @(
     'eastus', 'eastus2', 'westus',
     'westus2'
 )
 
 foreach ($location in $locationList) {
     $locationComboBoxRight.Items.Add($location) > $null
 } 
 
# Connect to Azure Button
$connectButton = New-Object Windows.Forms.Button
$connectButton.Text = "Connect to Azure"
$connectButton.Location = New-Object Drawing.Point(50, 10)
$connectButton.Size = New-Object Drawing.Size(550, 30)
$connectButton.Add_Click({
    # Login to Azure using Azure CLI
    $loginResult = az login 2>$null
    if ($loginResult) {
        [System.Windows.Forms.MessageBox]::Show("Connected to Azure.")
        
        # Fetch Resource Groups
        $rgList = az group list --query "[].name" -o tsv
        
       # Populate the first dropdown with resource groups
       $rgComboBox.Items.Clear()
       $rgList | ForEach-Object {
           $rgComboBox.Items.Add($_)
       }

       # Add a delay before populating the second dropdown
       Start-Sleep -Milliseconds 500

       # Populate the second dropdown with resource groups
       $vnetRGComboBox.Items.Clear()
       $rgList | ForEach-Object {
           $vnetRGComboBox.Items.Add($_)
       }

       if ($rgComboBox.Items.Count -eq 0) {
           [System.Windows.Forms.MessageBox]::Show("No resource groups found!")
       } else {
           $rgComboBox.SelectedIndex = 0
       }

       if ($vnetRGComboBox.Items.Count -eq 0) {
           [System.Windows.Forms.MessageBox]::Show("No resource groups found for VNets!")
       } else {
           $vnetRGComboBox.SelectedIndex = 0
       }
   } else {
       [System.Windows.Forms.MessageBox]::Show("Failed to connect to Azure.")
   }
 })
 $form.Controls.Add($connectButton)

# Fetch VNets and Storage Accounts when a Resource Group is selected
$vnetRGComboBox.add_SelectedIndexChanged({
   $selectedResourceGroup = $vnetRGComboBox.SelectedItem
   if ($selectedResourceGroup) {
       try {
           # Fetch VNets
           $vnetList = az network vnet list --resource-group $selectedResourceGroup --query "[].name" -o tsv
           $vnetComboBox.Items.Clear()
           $vnetList | ForEach-Object { $vnetComboBox.Items.Add($_) }
           if ($vnetComboBox.Items.Count -eq 0) {
               [System.Windows.Forms.MessageBox]::Show("No VNets found in the selected resource group!")
           } else {
               $vnetComboBox.SelectedIndex = 0
           }

           # Fetch Subnets for the selected VNet
           if ($vnetComboBox.SelectedItem) {
               $selectedVnet = $vnetComboBox.SelectedItem
               $subnetList = az network vnet subnet list --resource-group $selectedResourceGroup --vnet-name $selectedVnet --query "[].name" -o tsv
               $snetComboBox.Items.Clear()
               $subnetList | ForEach-Object { $snetComboBox.Items.Add($_) }
               if ($snetComboBox.Items.Count -eq 0) {
                   [System.Windows.Forms.MessageBox]::Show("No subnets found in the selected VNet!")
               } else {
                   $snetComboBox.SelectedIndex = 0
               }
           } else {
               [System.Windows.Forms.MessageBox]::Show("Please select a VNet first!")
           }

           # Fetch Subnets and the associated NSG for the selected VNet
           if ($vnetComboBox.SelectedItem) {
               $selectedVnet = $vnetComboBox.SelectedItem
               $subnetNSGList = az network nsg list --resource-group $selectedResourceGroup --query "[].{Name:name, NSG:id}" -o json
               $subnetNSGList = $subnetNSGList | ConvertFrom-Json
           
               $snetNSGComboBox.Items.Clear()
           
               # Check if any subnets are found and display them with the associated NSG
               if ($subnetNSGList.Count -eq 0) {
                   [System.Windows.Forms.MessageBox]::Show("No subnets found in the selected VNet!")
               } else {
                   foreach ($nsg in $subnetNSGList) {
                       # Add subnet name to the combo box, and display NSG ID if present
                       $nsgInfo = if ($nsg.Name) { "$($nsg.Name)" } else { "No NSG assigned" }
                       $snetNSGComboBox.Items.Add("$($nsgInfo)")
                   }
               
                   # Select the first subnet if available
                   $snetNSGComboBox.SelectedIndex = 0
               }
           } else {
               [System.Windows.Forms.MessageBox]::Show("Please select a VNet first!")
           }

           # Fetch Storage Accounts
           $storageList = az storage account list --resource-group $selectedResourceGroup --query "[].name" -o tsv
           $storageComboBox.Items.Clear()
           $storageList | ForEach-Object { $storageComboBox.Items.Add($_) }
           if ($storageComboBox.Items.Count -eq 0) {
               [System.Windows.Forms.MessageBox]::Show("No storage accounts found in the selected resource group!")
           } else {
               $storageComboBox.SelectedIndex = 0
           }
       } catch {
           [System.Windows.Forms.MessageBox]::Show("Error fetching resources: $_")
       }
   }
})

# Move existing controls inside the GroupBox
$azureInfoGroupBox.Controls.Add($vmNameLabel)
$azureInfoGroupBox.Controls.Add($vmNameTextBox)
# $azureInfoGroupBox.Controls.Add($countLabel)
# $azureInfoGroupBox.Controls.Add($countComboBox)
$azureInfoGroupBox.Controls.Add($rgLabel)
$azureInfoGroupBox.Controls.Add($rgComboBox)
$azureInfoGroupBox.Controls.Add($vnetLabel)
$azureInfoGroupBox.Controls.Add($vnetComboBox)
$azureInfoGroupBox.Controls.Add($vnetRGLabel)
$azureInfoGroupBox.Controls.Add($vnetRGComboBox)
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

# Bicep Param File label and textbox
$bicepFileLabel = New-Object Windows.Forms.Label
$bicepFileLabel.Text = "Bicep Param File*:"
$bicepFileLabel.Location = New-Object Drawing.Point(10, 420)
$form.Controls.Add($bicepFileLabel)

$bicepFilePathTextBox = New-Object Windows.Forms.TextBox
$bicepFilePathTextBox.Location = New-Object Drawing.Point(120, 420)
$bicepFilePathTextBox.Size = New-Object Drawing.Size(350, 30)
$bicepFilePathTextBox.ReadOnly = $true
$form.Controls.Add($bicepFilePathTextBox)

# Browse button for Bicep Param File
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

# Active Directory OU Selection
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

# Create and add a label for "Environment"
$labelEnv = New-Object Windows.Forms.Label
$labelEnv.Text = "Environment:"
$labelEnv.Location = New-Object Drawing.Point(280, 490)
$labelEnv.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($labelEnv)

# Create and add a ComboBox for Environment
$comboBoxEnv = New-Object Windows.Forms.ComboBox
$comboBoxEnv.Location = New-Object Drawing.Point(380, 490)
$comboBoxEnv.Size = New-Object Drawing.Size(200, 30)
$comboBoxEnv.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboBoxEnv)
$envSizes = @(
    'prod', 'dev', 'test'
)

foreach ($envSize in $envSizes) {
    $comboBoxEnv.Items.Add($envSize) > $null
}

# Create and add a label for "Department"
$labelDept = New-Object Windows.Forms.Label
$labelDept.Text = "Business Unit:"
$labelDept.Location = New-Object Drawing.Point(280, 530)
$labelDept.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($labelDept)

# Create and add a ComboBox for Department
$comboBoxDept = New-Object Windows.Forms.ComboBox
$comboBoxDept.Location = New-Object Drawing.Point(380, 530)
$comboBoxDept.Size = New-Object Drawing.Size(200, 30)
$comboBoxDept.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboBoxDept)
$deptSizes = @(
    'IT', 'HR', 'Finance'
)

foreach ($deptSize in $deptSizes) {
    $comboBoxDept.Items.Add($deptSize) > $null
}

# Create and add a label for "Owner"
$labelOwner = New-Object Windows.Forms.Label
$labelOwner.Text = "Owner:"
$labelOwner.Location = New-Object Drawing.Point(280, 570)
$labelOwner.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($labelOwner)

# Create and add a ComboBox for Owner
$comboBoxOwner = New-Object Windows.Forms.ComboBox
$comboBoxOwner.Location = New-Object Drawing.Point(380, 570)
$comboBoxOwner.Size = New-Object Drawing.Size(200, 30)
$comboBoxOwner.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboBoxOwner)
$ownerSizes = @(
    'Server Team', 'Application Team', 'Web Team'
)

foreach ($ownerSize in $ownerSizes) {
    $comboBoxOwner.Items.Add($ownerSize) > $null
}

# Create and add a label for "Application"
$labelApp = New-Object Windows.Forms.Label
$labelApp.Text = "Application:"
$labelApp.Location = New-Object Drawing.Point(280, 610)
$labelApp.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($labelApp)

# Create and add a ComboBox for Owner
$comboBoxApp = New-Object Windows.Forms.ComboBox
$comboBoxApp.Location = New-Object Drawing.Point(380, 610)
$comboBoxApp.Size = New-Object Drawing.Size(200, 30)
$comboBoxApp.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboBoxApp)
$appSizes = @(
    'VS Code', 'Net App', 'CommVault'
)

foreach ($appSize in $appSizes) {
    $comboBoxApp.Items.Add($appSize) > $null
}

# Load Active Directory OUs into TreeView
function Load-OUs {
   param (
       [string]$baseDN = 'DC=example,DC=com'
   )
   try {
       $searcher = New-Object DirectoryServices.DirectorySearcher
       $searcher.SearchRoot = New-Object DirectoryServices.DirectoryEntry("LDAP://$baseDN")
       $searcher.Filter = "(objectClass=organizationalUnit)"
       $searcher.SearchScope = [System.DirectoryServices.SearchScope]::OneLevel

       $searcher.FindAll() | ForEach-Object {
           $entry = $_.GetDirectoryEntry()
           $node = New-Object Windows.Forms.TreeNode
           $node.Text = $entry.Properties["name"][0]
           $node.Tag = $entry.Properties["distinguishedName"][0]
           $node.Nodes.Add("Loading...")
           $adTreeView.Nodes.Add($node)
       }
   } catch {
       [System.Windows.Forms.MessageBox]::Show("Error loading Active Directory: $_")
   }
}

# Expand event to load child OUs lazily
$adTreeView.add_BeforeExpand({
   $node = $_.Node
   if ($node.Nodes[0].Text -eq "Loading...") {
       $node.Nodes.Clear()
       $searcher = New-Object DirectoryServices.DirectorySearcher
       $searcher.SearchRoot = New-Object DirectoryServices.DirectoryEntry("LDAP://$($node.Tag)")
       $searcher.Filter = "(objectClass=organizationalUnit)"
       $searcher.SearchScope = [System.DirectoryServices.SearchScope]::OneLevel

       $searcher.FindAll() | ForEach-Object {
           $entry = $_.GetDirectoryEntry()
           $childNode = New-Object Windows.Forms.TreeNode
           $childNode.Text = $entry.Properties["name"][0]
           $childNode.Tag = $entry.Properties["distinguishedName"][0]
           $childNode.Nodes.Add("Loading...")
           $node.Nodes.Add($childNode)
       }
   }
})

# Select OU on click
$adTreeView.add_NodeMouseClick({
   $selectedNode = $_.Node
   $selectedOUTextBox.Text = $selectedNode.Tag
})

# Submit button
$submitButton = New-Object Windows.Forms.Button
$submitButton.Text = "Create VM"
$submitButton.Location = New-Object Drawing.Point(30, 650)
$submitButton.Size = New-Object Drawing.Size(600, 30)
$submitButton.Add_Click({
   $vmName = $vmNameTextBox.Text
   #$vmCount = $countComboBox.SelectedItem
   $resourceGroup = $rgComboBox.SelectedItem
   $vnetName = $vnetComboBox.SelectedItem
   $vNetResourceGroup = $vnetRGComboBox.SelectedItem
   $storageAccount = $storageComboBox.SelectedItem
   $snet = $snetComboBox.SelectedItem
   $nsg = $snetNSGComboBox.SelectedItem
   $vmSize = $vmSizeComboBoxRight.SelectedItem
   $storageType = $storageTypeComboBoxRight.SelectedItem
   $os = $osComboBoxRight.SelectedItem
   $ip = $ipTextBoxRight.Text
   $env = $comboBoxEnv.SelectedItem
   $owner = $comboBoxOwner.SelectedItem
   $dept = $comboBoxDept.SelectedItem
   $app = $comboBoxApp.SelectedItem
   $selectedOU = $selectedOUTextBox.Text
   $bicepParamFile = $bicepFilePathTextBox.Text
   $location = $locationComboBoxRight.SelectedItem


   if ([string]::IsNullOrWhiteSpace($vmName) -or [string]::IsNullOrWhiteSpace($resourceGroup) -or 
       [string]::IsNullOrWhiteSpace($vnetName) -or [string]::IsNullOrWhiteSpace($storageAccount) -or 
       [string]::IsNullOrWhiteSpace($selectedOU)) {
       [System.Windows.Forms.MessageBox]::Show('Please fill in all fields!')
       return
   }

   try {
       # Always include both the parameter file and inline parameters in the command
       $bicepCommand = @"
       az deployment group create `
           --resource-group $resourceGroup `
           --template-file ./main.bicep `
           --parameters @$bicepParamFile `
           vmName='$vmName' `
           vnetName='$vnetName' `
           vNetResourceGroup=$vNetResourceGroup `
           subnetName='$snet' `
           NSG=$nsg `
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
           ouDistinguishedName='$selectedOU'
"@

       # Execute the Bicep deployment
       Invoke-Expression $bicepCommand
       [System.Windows.Forms.MessageBox]::Show('VM Creation Successful!')
   } catch {
       [System.Windows.Forms.MessageBox]::Show("Error creating VM: $_")
   }
})
$form.Controls.Add($submitButton)

# Load OUs when form is initialized
Load-OUs | Out-Null

# Initialize the form
$form.ShowDialog() | Out-Null