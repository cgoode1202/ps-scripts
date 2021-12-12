<# To hold the selected location, define a PowerShell variable#>
$location = (Get-AzResourceGroup -name testVM-rg).location

<# Next, define a few more convenient variables to capture the name of the VM and the resource group#>
$vmName = "fmdata-vm01"
$rgName = "testVM-rg"

<# Create a new VM#>
New-AzVm `
    -ResourceGroupName $rgName `
    -Name $vmName `
    -Location $location `
    -OpenPorts 3389

<#After the VM finishes deploying, capture the VM details in a variable. 
You can use this variable to explore what was created.#>
$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName

You can see the OS disk attached to the VM.
$vm.StorageProfile.OSDisk

<#Check the current status of encryption on the OS disk (and any data disks).#>
Get-AzVmDiskEncryptionStatus  `
    -ResourceGroupName $rgName `
    -VMName $vmName

