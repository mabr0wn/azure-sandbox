# Login
Login-AzAccount

Get-AzSubscription

Set-AzContext -SubscriptionId "77ab2927-7bf2-4427-bb1d-05ce374d92e1"

# Variables for common values
$location = 'eastus';
$resourceGroup = 'lab-resgroup-0';
$vmName = 'labvm-0';
$publicIP = 'spublicip-1';
$subnet = 'subnet-1';
$vnet = 'vnet-1';
$nsg = 'nsg-1';
$nsgrdp = 'nsgrdp-1';
$nsgwww = 'nsgwww-1';
$nsgweb1 = 'nsgweb1-1';
$nsgweb2 = 'nsgweb2-2';
$nic = 'nic-1';

# create resource group
New-AzResourceGroup -ResourceGroupName $resourceGroup -Location $location

# Get vm credentials
$cred = Get-Credential

# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name $subnet `
    -AddressPrefix 192.168.1.0/24

# create a virtual network
$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name $vnet `
    -AddressPrefix 192.168.0.0/16 `
    -Subnet $subnetConfig

# create the public IP address and specify a DNS name
$publicIP = New-AzPublicIpAddress `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -AllocationMethod Static `
    -IdleTimeoutInMinutes 4 `
    -Name $publicIP

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig `
    -Name $nsgrdp `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1000 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 3389 `
    -Access Allow

# create an inbound network security group for port 80
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
    -Name $nsgwww `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1001 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 80 `
    -Access Allow

# create an inbound network security group for port 8081
$nsgRuleWeb1 = New-AzNetworkSecurityRuleConfig `
    -Name $nsgweb1 `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1002 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 8081 `
    -Access Allow

# create an inbound network security group for port 8082
$nsgRuleWeb2 = New-AzNetworkSecurityRuleConfig `
    -Name $nsgweb2 `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1003 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 8082 `
    -Access Allow

# create the network security group
$nsg = New-AzNetworkSecurityGroup `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name $nsg `
    -SecurityRules $nsgRuleRDP, $nsgRuleWeb, $nsgRuleWeb1, $nsgRuleWeb2

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface `
    -Name $nic `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -SubnetId $vnet.Subnets[0].Id `
    -PublicIpAddressId $publicIP.Id `
    -NetworkSecurityGroupId $nsg.Id

$vmConfig = @{
        ResourceGroupName = $resourceGroup
        Name = $vmName
        Location = $location
        ImageName = 'Win2016Datacenter'
        PublicIpAddressName = $publicIP
        Credential = $cred
        OpenPorts = 3389
        Size = 'Standard_D2s_v3'
      }
      $newVM1 = New-AzVM @vmConfig

$newVM1

$tag = @{
    owner='Matt Brown'; lab_vm='windows server'
}

New-AzTag -Tag $tag -ResourceId $newVM1.Id -Verbose

# create a virtual machine configuration
# $vmConfig = New-AzVMConfig -VMName $vmName -VMSize Standard_D1 | `
# Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
# Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer `
#     -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
# Add-AzVMNetworkInterface -Id $nic.Id

# # Createa virtual machine using the configuration 
# New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig -Verbose

# Create a virtual machine using the configuration
Set-AzVMExtension -ResourceGroupName $resourceGroup `
    -ExtensionName IIS `
    -VMName $vmName `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.4 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server,Web-Mgmt-Tools,Web-Asp-Net45,NET-Framework-Features;powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' `
    -Location $location

# Get public ip address of the machine
Get-AzPublicIpAddress -ResourceGroupName $resourceGroup
