Add-Type -AssemblyName System.Windows.Forms

$form = New-Object Windows.Forms.Form
$form.Text = 'Create Azure VM'
$form.Size = New-Object Drawing.Size(400, 300)

# VM Name label and textbox
$vmNameLabel = New-Object Windows.Forms.Label
$vmNameLabel.Text = "VM Name"
$vmNameLabel.Location = New-Object Drawing.Point(10, 20)
$vmNameLabel.Size = New-Object Drawing.Size(80, 30)
$form.Controls.Add($vmNameLabel)

$vmNameTextBox = New-Object Windows.Forms.TextBox
$vmNameTextBox.Location = New-Object Drawing.Point(100, 20)
$form.Controls.Add($vmNameTextBox)


# Button to connect to Azure and retrieve resource groups
$connectButton = New-Object Windows.Forms.Button
$connectButton.Text = "Connect to Azure"
$connectButton.Location = New-Object Drawing.Point(100, 100)
$connectButton.Size = New-Object Drawing.Size(250, 30)
$connectButton.Add_Click({
    # Login to Azure using Azure CLI
    $loginResult = az login --tenant 3b22d4ab-9fa6-4c14-a370-1ac8eaad49da
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

# Resource Group label
$rgLabel = New-Object Windows.Forms.Label
$rgLabel.Text = "Resource Group"
$rgLabel.Location = New-Object Drawing.Point(10, 60)
$rgLabel.Size = New-Object Drawing.Size(80, 30)
$form.Controls.Add($rgLabel)

# Resource Group dropdown (ComboBox)
$rgComboBox = New-Object Windows.Forms.ComboBox
$rgComboBox.Location = New-Object Drawing.Point(100, 60)
$rgComboBox.Size = New-Object Drawing.Size(250, 30)
$rgComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($rgComboBox)

# Username label and textbox
$usernameLabel = New-Object Windows.Forms.Label
$usernameLabel.Text = "Admin Username"
$usernameLabel.Location = New-Object Drawing.Point(10, 140)
$form.Controls.Add($usernameLabel)

$usernameTextBox = New-Object Windows.Forms.TextBox
$usernameTextBox.Location = New-Object Drawing.Point(100, 140)
$form.Controls.Add($usernameTextBox)

# Password label and textbox
$passwordLabel = New-Object Windows.Forms.Label
$passwordLabel.Text = "Admin Password"
$passwordLabel.Location = New-Object Drawing.Point(10, 170)
$form.Controls.Add($passwordLabel)

$passwordTextBox = New-Object Windows.Forms.TextBox
$passwordTextBox.Location = New-Object Drawing.Point(100, 170)
$passwordTextBox.PasswordChar = '*'
$form.Controls.Add($passwordTextBox)

# Button to submit and create the VM
$submitButton = New-Object Windows.Forms.Button
$submitButton.Text = "Create VM"
$submitButton.Location = New-Object Drawing.Point(100, 210)
$submitButton.Add_Click({
    $vmName = $vmNameTextBox.Text
    $resourceGroup = $rgComboBox.SelectedItem
    $username = $usernameTextBox.Text
    $password = $passwordTextBox.Text

    if ([string]::IsNullOrWhiteSpace($vmName) -or [string]::IsNullOrWhiteSpace($resourceGroup) -or [string]::IsNullOrWhiteSpace($username) -or [string]::IsNullOrWhiteSpace($password)) {
        [System.Windows.Forms.MessageBox]::Show('Please fill in all fields!')
        return
    }

    # Call the Azure CLI or use a script to deploy the Bicep template with the provided parameters
    $bicepCommand = "az deployment group create --resource-group $resourceGroup --template-file ../../templates/create-virtual-machine/main.bicepparam --parameters adminUsername='$username' adminPassword='$password' vmName='$vmName'"
    Invoke-Expression $bicepCommand
    [System.Windows.Forms.MessageBox]::Show('VM deployment started!')
    $form.Close()
})
$form.Controls.Add($submitButton)

$form.ShowDialog()
 
