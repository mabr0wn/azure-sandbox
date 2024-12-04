Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object Windows.Forms.Form
$form.Text = 'Create Azure VM'
$form.Size = New-Object Drawing.Size(600, 700)

# VM Name Section
$vmNameLabel = New-Object Windows.Forms.Label
$vmNameLabel.Text = "VM Name"
$vmNameLabel.Location = New-Object Drawing.Point(10, 60)
$vmNameLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vmNameLabel)

$vmNameTextBox = New-Object Windows.Forms.TextBox
$vmNameTextBox.Location = New-Object Drawing.Point(120, 60)
$vmNameTextBox.Size = New-Object Drawing.Size(200, 30)
$form.Controls.Add($vmNameTextBox)

# Resource Group Section
$rgLabel = New-Object Windows.Forms.Label
$rgLabel.Text = "Resource Group"
$rgLabel.Location = New-Object Drawing.Point(10, 100)
$rgLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($rgLabel)

$rgComboBox = New-Object Windows.Forms.ComboBox
$rgComboBox.Location = New-Object Drawing.Point(120, 100)
$rgComboBox.Size = New-Object Drawing.Size(200, 30)
$rgComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($rgComboBox)

# VNet Section
$vnetLabel = New-Object Windows.Forms.Label
$vnetLabel.Text = "VNET Name"
$vnetLabel.Location = New-Object Drawing.Point(10, 140)
$vnetLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($vnetLabel)

$vnetComboBox = New-Object Windows.Forms.ComboBox
$vnetComboBox.Location = New-Object Drawing.Point(120, 140)
$vnetComboBox.Size = New-Object Drawing.Size(200, 30)
$vnetComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($vnetComboBox)

# Storage Account Section
$storageLabel = New-Object Windows.Forms.Label
$storageLabel.Text = "Storage Group"
$storageLabel.Location = New-Object Drawing.Point(10, 180)
$storageLabel.Size = New-Object Drawing.Size(100, 30)
$form.Controls.Add($storageLabel)

$storageComboBox = New-Object Windows.Forms.ComboBox
$storageComboBox.Location = New-Object Drawing.Point(120, 180)
$storageComboBox.Size = New-Object Drawing.Size(200, 30)
$storageComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($storageComboBox)

# Connect to Azure Button
$connectButton = New-Object Windows.Forms.Button
$connectButton.Text = "Connect to Azure"
$connectButton.Location = New-Object Drawing.Point(10, 10)
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
$bicepFileLabel.Text = "Bicep Param File"
$bicepFileLabel.Location = New-Object Drawing.Point(10, 220)
$form.Controls.Add($bicepFileLabel)

$bicepFilePathTextBox = New-Object Windows.Forms.TextBox
$bicepFilePathTextBox.Location = New-Object Drawing.Point(120, 220)
$bicepFilePathTextBox.Size = New-Object Drawing.Size(350, 30)
$bicepFilePathTextBox.ReadOnly = $true
$form.Controls.Add($bicepFilePathTextBox)

# Browse button for Bicep Param File
$fileBrowseButton = New-Object Windows.Forms.Button
$fileBrowseButton.Text = "Browse"
$fileBrowseButton.Location = New-Object Drawing.Point(480, 220)
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
$ouLabel.Text = "Active Directory OU"
$ouLabel.Location = New-Object Drawing.Point(10, 260)
$ouLabel.Size = New-Object Drawing.Size(150, 30)
$form.Controls.Add($ouLabel)

$selectedOUTextBox = New-Object Windows.Forms.TextBox
$selectedOUTextBox.Location = New-Object Drawing.Point(10, 300)
$selectedOUTextBox.Size = New-Object Drawing.Size(550, 30)
$selectedOUTextBox.ReadOnly = $true
$form.Controls.Add($selectedOUTextBox)

$adTreeView = New-Object Windows.Forms.TreeView
$adTreeView.Location = New-Object Drawing.Point(10, 340)
$adTreeView.Size = New-Object Drawing.Size(550, 250)
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
$submitButton.Location = New-Object Drawing.Point(10, 600)
$submitButton.Size = New-Object Drawing.Size(550, 30)
$submitButton.Add_Click({
   $vmName = $vmNameTextBox.Text
   $resourceGroup = $rgComboBox.SelectedItem
   $vnetName = $vnetComboBox.SelectedItem
   $storageAccount = $storageComboBox.SelectedItem
   $selectedOU = $selectedOUTextBox.Text

   if ([string]::IsNullOrWhiteSpace($vmName) -or [string]::IsNullOrWhiteSpace($resourceGroup) -or 
       [string]::IsNullOrWhiteSpace($vnetName) -or [string]::IsNullOrWhiteSpace($storageAccount) -or 
       [string]::IsNullOrWhiteSpace($selectedOU)) {
       [System.Windows.Forms.MessageBox]::Show('Please fill in all fields!')
       return
   }

   try {
       $bicepCommand = "az deployment group create --resource-group $resourceGroup --template-file ./myTemplate.bicep --parameters vmName='$vmName' vnetName='$vnetName' storageAccount='$storageAccount' ouDistinguishedName='$selectedOU'"
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