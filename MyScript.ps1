# Import the Azure PowerShell module.
Import-Module -Name Az

# Connect to an Azure account.
Connect-AzAccount

# Define Azure variables for a virtual machine.
$vmName = "WingtiptoysVM"
$resourceGroup = "WingtiptoysRG"

# Create Azure credentials.
$adminCredential = Get-Credential -Message "Enter a username and password for the VM administrator."

# Create a virtual machine in Azure.
New-AzVm -ResourceGroupName $resourceGroup -Name $vmName -Credential $adminCredential -Image UbuntuLTS

# Here is a new line to push test commit on Github
