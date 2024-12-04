Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object Windows.Forms.Form
$form.Text = 'Create Azure VM'
$form.Size = New-Object Drawing.Size(675, 700)

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

# VNet Section (Left)
$vnetLabel = New-Object Windows.Forms.Label
$vnetLabel.Text = "Vnet Name*:"
$vnetLabel.Location = New-Object Drawing.Point(10, 140)
$vnetLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vnetLabel)

$vnetComboBox = New-Object Windows.Forms.ComboBox
$vnetComboBox.Location = New-Object Drawing.Point(120, 140)
$vnetComboBox.Size = New-Object Drawing.Size(200, 30)
$vnetComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($vnetComboBox)

# Subnet Section (Left)
$snetLabel = New-Object Windows.Forms.Label
$snetLabel.Text = "Subnet Name*:"
$snetLabel.Location = New-Object Drawing.Point(10, 180)
$snetLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($snetLabel)

$snetComboBox = New-Object Windows.Forms.ComboBox
$snetComboBox.Location = New-Object Drawing.Point(120, 180)
$snetComboBox.Size = New-Object Drawing.Size(200, 30)
$snetComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($snetComboBox)

# Storage Account Section (Left)
$storageLabel = New-Object Windows.Forms.Label
$storageLabel.Text = "Storage Group*:"
$storageLabel.Location = New-Object Drawing.Point(10, 220)
$storageLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($storageLabel)

$storageComboBox = New-Object Windows.Forms.ComboBox
$storageComboBox.Location = New-Object Drawing.Point(120, 220)
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

$vmSizeComboBoxRight.Items.Add('Standard_DS1_v2')
$vmSizeComboBoxRight.Items.Add('Standard_DS2_v2')
$vmSizeComboBoxRight.Items.Add('Standard_DS3_v2')
$vmSizeComboBoxRight.Items.Add('Standard_DS4_v2')
$vmSizeComboBoxRight.Items.Add('Standard_D1_v2')
$vmSizeComboBoxRight.Items.Add('Standard_D2_v2')
$vmSizeComboBoxRight.Items.Add('Standard_D3_v2')
$vmSizeComboBoxRight.Items.Add('Standard_D4_v2')
$vmSizeComboBoxRight.Items.Add('Standard_D5_v2')
$vmSizeComboBoxRight.Items.Add('Standard_F1')

# VNet Section (Right)
$storageTypeLabelRight = New-Object Windows.Forms.Label
$storageTypeLabelRight.Text = "Storage Type*:"
$storageTypeLabelRight.Location = New-Object Drawing.Point(330, 140)
$storageTypeLabelRight.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($storageTypeLabelRight)

$storageTypeComboBoxRight = New-Object Windows.Forms.ComboBox
$storageTypeComboBoxRight.Location = New-Object Drawing.Point(440, 140)
$storageTypeComboBoxRight.Size = New-Object Drawing.Size(200, 30)
$storageTypeComboBoxRight.DropDownStyle = 'DropDownList'

# Add OS options to the ComboBox
$storageTypeComboBoxRight.Items.Add('Premium_LRS')
$storageTypeComboBoxRight.Items.Add('Premium_ZRS')
$storageTypeComboBoxRight.Items.Add('Standard_GRS')
$storageTypeComboBoxRight.Items.Add('Standard_GZRS')
$storageTypeComboBoxRight.Items.Add('Standard_LRS')
$storageTypeComboBoxRight.Items.Add('Standard_RAGRS')
$storageTypeComboBoxRight.Items.Add('Standard_RAGZRS')
$storageTypeComboBoxRight.Items.Add('Standard_ZRS')
$storageTypeComboBoxRight.Items.Add('StandardSSD_LRS')

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
$osComboBoxRight.Items.Add('Server2016')
$osComboBoxRight.Items.Add('Server2019')
$osComboBoxRight.Items.Add('Server2022')
$osComboBoxRight.Items.Add('Ubuntu1804')
$osComboBoxRight.Items.Add('Ubuntu2004')
$osComboBoxRight.Items.Add('Ubuntu2204')
$osComboBoxRight.Items.Add('Debian11')
$osComboBoxRight.Items.Add('CentOS7')
$osComboBoxRight.Items.Add('CentOS8')
$osComboBoxRight.Items.Add('RHEL8')
$osComboBoxRight.Items.Add('RHEL9')
$osComboBoxRight.Items.Add('SLES12')
$osComboBoxRight.Items.Add('SLES15')
$osComboBoxRight.Items.Add('AlmaLinux8')
$osComboBoxRight.Items.Add('OracleLinux7')
$osComboBoxRight.Items.Add('OracleLinux8')
$osComboBoxRight.Items.Add('FlatcarContainerLinux')
$osComboBoxRight.Items.Add('WindowsServerCore2016')
$osComboBoxRight.Items.Add('WindowsServerCore2019')
$osComboBoxRight.Items.Add('WindowsServerCore2022')

# Extra Section (Right)
#$labelRight = New-Object Windows.Forms.Label
#$labelRight.Text = "Storage Group (Right)"
#$labelRight.Location = New-Object Drawing.Point(330, 220)
#$labelRight.Size = New-Object Drawing.Size(100, 30)
#$form.Controls.Add($labelRight)

#$comboBoxRight = New-Object Windows.Forms.ComboBox
#$comboBoxRight.Location = New-Object Drawing.Point(440, 220)
#$comboBoxRight.Size = New-Object Drawing.Size(200, 30)
#$comboBoxRight.DropDownStyle = 'DropDownList'
#$form.Controls.Add($comboBoxRight)

# Connect to Azure Button
$connectButton = New-Object Windows.Forms.Button
$connectButton.Text = "Connect to Azure"
$connectButton.Location = New-Object Drawing.Point(50, 10)
$connectButton.Size = New-Object Drawing.Size(550, 30)
$connectButton.Add_Click({
   # Login to Azure using Azure CLI
   $loginResult = az login
   if ($loginResult) {
       [System.Windows.Forms.MessageBox]::Show("Connected to Azure.")
       
       # Fetch Resource Groups
       $rgList = az group list --query "[].name" -o tsv
       
       # Populate the dropdown with resource groups
       $rgComboBox.Items.Clear()
       $rgList | ForEach-Object { $rgComboBox.Items.Add($_) }
       
       if ($rgComboBox.Items.Count -eq 0) {
           [System.Windows.Forms.MessageBox]::Show("No resource groups found!")
       } else {
           $rgComboBox.SelectedIndex = 0
       }
   } else {
       [System.Windows.Forms.MessageBox]::Show("Failed to connect to Azure.")
   }
})
$form.Controls.Add($connectButton)

# Fetch VNets and Storage Accounts when a Resource Group is selected
$rgComboBox.add_SelectedIndexChanged({
   $selectedResourceGroup = $rgComboBox.SelectedItem
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

# Bicep Param File label and textbox
$bicepFileLabel = New-Object Windows.Forms.Label
$bicepFileLabel.Text = "Bicep Param File*:"
$bicepFileLabel.Location = New-Object Drawing.Point(10, 260)
$form.Controls.Add($bicepFileLabel)

$bicepFilePathTextBox = New-Object Windows.Forms.TextBox
$bicepFilePathTextBox.Location = New-Object Drawing.Point(120, 260)
$bicepFilePathTextBox.Size = New-Object Drawing.Size(350, 30)
$bicepFilePathTextBox.ReadOnly = $true
$form.Controls.Add($bicepFilePathTextBox)

# Browse button for Bicep Param File
$fileBrowseButton = New-Object Windows.Forms.Button
$fileBrowseButton.Text = "Browse"
$fileBrowseButton.Location = New-Object Drawing.Point(480, 260)
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
$ouLabel.Location = New-Object Drawing.Point(10, 310)
$ouLabel.Size = New-Object Drawing.Size(30, 30)
$form.Controls.Add($ouLabel)

$selectedOUTextBox = New-Object Windows.Forms.TextBox
$selectedOUTextBox.Location = New-Object Drawing.Point(120, 310)
$selectedOUTextBox.Size = New-Object Drawing.Size(350, 30)
$selectedOUTextBox.ReadOnly = $true
$form.Controls.Add($selectedOUTextBox)

$adTreeView = New-Object Windows.Forms.TreeView
$adTreeView.Location = New-Object Drawing.Point(10, 350)
$adTreeView.Size = New-Object Drawing.Size(250, 250)
$form.Controls.Add($adTreeView)

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
$submitButton.Location = New-Object Drawing.Point(30, 620)
$submitButton.Size = New-Object Drawing.Size(600, 30)
$submitButton.Add_Click({
   $vmName = $vmNameTextBox.Text
   $resourceGroup = $rgComboBox.SelectedItem
   $vnetName = $vnetComboBox.SelectedItem
   $storageAccount = $storageComboBox.SelectedItem
   $snet = $snetComboBox.SelectedItem
   $vmSize = $vmSizeComboBoxRight.SelectedItem
   $storageType = $storageTypeComboBoxRight.SelectedItem
   $os = $osComboBoxRight.SelectedItem
   $selectedOU = $selectedOUTextBox.Text
   $bicepParamFile = $bicepFilePathTextBox.Text


   if ([string]::IsNullOrWhiteSpace($vmName) -or [string]::IsNullOrWhiteSpace($resourceGroup) -or 
       [string]::IsNullOrWhiteSpace($vnetName) -or [string]::IsNullOrWhiteSpace($storageAccount) -or 
       [string]::IsNullOrWhiteSpace($selectedOU)) {
       [System.Windows.Forms.MessageBox]::Show('Please fill in all fields!')
       return
   }

   try {
       # Always include both the parameter file and inline parameters in the command
       $bicepCommand = "az deployment group create --resource-group $resourceGroup --template-file ./main.bicep --parameters @$bicepParamFile vmName='$vmName' vnetName='$vnetName' subnetName='$snet' storageAccountName='$storageAccount' vmSize='$vmSize' storageAccountType='$storageType' OS='$os' ouDistinguishedName='$selectedOU'"

       # Execute the Bicep deployment
       Invoke-Expression $bicepCommand
       [System.Windows.Forms.MessageBox]::Show('VM Creation Successful!')
   } catch {
       [System.Windows.Forms.MessageBox]::Show("Error creating VM: $_")
   }
})
$form.Controls.Add($submitButton)

# Load OUs when form is initialized
Load-OUs

# Initialize the form
$form.ShowDialog()  
