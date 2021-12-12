# Install Azure module for PS
# Make sure to run PS as admin!
Install-Module Az

# Connect Azure Account to PS
Connect-AzAccount

# Assign Location to a variable and create a resource group
$Location="WestUS2" 
New-AzResourceGroup -Name vm-networks -Location $Location

# Create a subnet and virtual network
$Subnet=New-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix 10.0.0.0/24
 New-AzVirtualNetwork -Name myVnet `
 -ResourceGroupName vm-networks `
 -Location $Location `
 -AddressPrefix 10.0.0.0/16 `
 -Subnet $Subnet

 # Create first VM
 New-AzVm `
 -ResourceGroupName "vm-networks" `
 -Name "dataProcStage1" `
 -VirtualNetworkName "myVnet" `
 -SubnetName "default" `
 -image "Win2016Datacenter" `
 -Size "Standard_DS2_v2"

 # Get the public IP address of the newly created VM
 Get-AzPublicIpAddress -Name dataProcStage1

 # Create second VM
 New-AzVm `
 -ResourceGroupName "vm-networks" `
 -Name "dataProcStage2" `
 -VirtualNetworkName "myVnet" `
 -SubnetName "default" `
 -image "Win2016Datacenter" `
 -Size "Standard_DS2_v2"

 # Disassociate the public IP address tath was created by default for the VM
$nic = Get-AzNetworkInterface -Name dataProcStage2 -ResourceGroup vm-networks
$nic.IpConfigurations.publicipaddress.id = $null
Set-AzNetworkInterface -NetworkInterface $nic

# Connect to VM from PS command line
mstsc /v:publicIpAddress

# Launch 2nd VM from within the 1st
# On dataProcStage2, select the Start Menu, enter Firewall, and press Enter
# In the right-hand pane, scroll down, right-click File and Printer Sharing 
# (Echo Request - ICMPv4-In), and then confirm that Enable Rule is enabled.
# Switch back to the dataProcStage1 remote session, and run the following command in the command prompt
ping dataProcStage2 -4

# You can now ping the 2nd VM from the 1st one