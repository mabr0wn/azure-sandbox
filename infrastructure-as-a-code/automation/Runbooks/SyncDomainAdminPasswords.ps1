# Variables
$domain = (Read-Host "Enter your domain name, i.e. yourdomain.local")
$domainAdminGroup = "Domain Admins"
$keyVaultName = (Read-Host "Enter your your-key-vault-name")
$keyVaultSecretPrefix = "DomainAdminPassword-"
$runbookName = "SyncDomainAdminPasswords"

# Import the necessary modules
Import-Module ActiveDirectory
Import-Module Az.KeyVault

# Get Domain Admins users
$domainAdmins = Get-ADGroupMember -Identity $domainAdminGroup -Recursive | Where-Object { $_.objectClass -eq "user" }

foreach ($admin in $domainAdmins) {
    $username = $admin.SamAccountName

    # Get the current password from the Active Directory
    $user = Get-ADUser -Identity $username -Properties PasswordLastSet

    # Here, replace this with your method of retrieving the new password
    # This is a placeholder for demonstration
    $newPassword = "YourNewPasswordMethod"

    # Update Key Vault
    $secretName = "$keyVaultSecretPrefix$username"
    $existingSecret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -ErrorAction SilentlyContinue
    
    if ($existingSecret) {
        Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $newPassword
    } else {
        Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $newPassword
    }
}

# Notify success
Write-Output "Domain Admin passwords synced to Key Vault successfully."
