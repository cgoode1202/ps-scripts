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