Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = "Create Azure Resource Groups"
$form.Size = New-Object Drawing.Size(500, 300)

# RG base name
$rgLabel = New-Object Windows.Forms.Label
$rgLabel.Text = "Base Name (e.g., dev-rg):"
$rgLabel.Location = New-Object Drawing.Point(20, 30)
$rgLabel.Size = New-Object Drawing.Size(150, 30)
$form.Controls.Add($rgLabel)

$rgTextBox = New-Object Windows.Forms.TextBox
$rgTextBox.Location = New-Object Drawing.Point(180, 30)
$rgTextBox.Size = New-Object Drawing.Size(250, 30)
$form.Controls.Add($rgTextBox)

# Location selection
$locLabel = New-Object Windows.Forms.Label
$locLabel.Text = "Select Locations:"
$locLabel.Location = New-Object Drawing.Point(20, 70)
$locLabel.Size = New-Object Drawing.Size(150, 30)
$form.Controls.Add($locLabel)

$locationListBox = New-Object Windows.Forms.CheckedListBox
$locationListBox.Location = New-Object Drawing.Point(180, 70)
$locationListBox.Size = New-Object Drawing.Size(250, 100)
$form.Controls.Add($locationListBox)

@('eastus', 'westus', 'centralus', 'eastus2', 'westus2') | ForEach-Object {
    [void]$locationListBox.Items.Add($_)
}

# Repo path
$repoPathLabel = New-Object Windows.Forms.Label
$repoPathLabel.Text = "Git Repo Path:"
$repoPathLabel.Location = New-Object Drawing.Point(20, 180)
$repoPathLabel.Size = New-Object Drawing.Size(150, 30)
$form.Controls.Add($repoPathLabel)

$repoPathBox = New-Object Windows.Forms.TextBox
$repoPathBox.Location = New-Object Drawing.Point(180, 180)
$repoPathBox.Size = New-Object Drawing.Size(250, 30)
$form.Controls.Add($repoPathBox)

# Submit Button
$submitButton = New-Object Windows.Forms.Button
$submitButton.Text = "Generate & Push"
$submitButton.Location = New-Object Drawing.Point(150, 220)
$submitButton.Size = New-Object Drawing.Size(180, 30)

$submitButton.Add_Click({
    $baseName = $rgTextBox.Text
    $repoPath = $repoPathBox.Text
    $locations = @()

    foreach ($item in $locationListBox.CheckedItems) {
        $locations += $item
    }

    if (-not $baseName -or -not $repoPath -or $locations.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all fields and select at least one location.")
        return
    }

    # Construct .bicepparam content
    $paramContent = @"
using 'main.bicep'

param baseName = '$baseName'
param locations = [
$(($locations | ForEach-Object { "'$_'" }) -join "`n")
]
"@

    try {
        $paramPath = Join-Path $repoPath ".bicep\main.bicepparam"
        Set-Content -Path $paramPath -Value $paramContent -Force

        Set-Location $repoPath
        git add .
        git commit -m "Auto-create RGs: $baseName in [$($locations -join ', ')]"
        git push origin main

        [System.Windows.Forms.MessageBox]::Show("RG param file committed and pushed to GitHub!")

    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $_")
    }
})
$form.Controls.Add($submitButton)

# Run the form
$form.ShowDialog() | Out-Null
