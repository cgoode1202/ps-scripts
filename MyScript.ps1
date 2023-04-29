# Import the Azure PowerShell module.
Import-Module -Name Az

# Connect to an Azure account.
Connect-AzAccount

# Create a resource group
New-AzResourceGroup -Location 'location' -Name 'name'

# Retrivew list of resource groups
Get-AzResourceGroup

# Define Azure variables for a virtual machine.
$vmName = "WingtiptoysVM"
$resourceGroup = "WingtiptoysRG"

# Create Azure credentials.
$adminCredential = Get-Credential -Message "Enter a username and password for the VM administrator."

# Create a virtual machine in Azure.
New-AzVm -ResourceGroupName $resourceGroup -Name $vmName -Credential $adminCredential -Image UbuntuLTS

# Create a new file in current folder
New-Item test.txt

# add content to text file
Set-Content test.txt 'here is some sample text'

# Read content of file
get-Content test.txt

# Deploy a bicep template from Azure CLI
az deployment group create --template-file main.bicep --resource-group $rgName

# Create a new storage account with a randomized name
New-AzStorageAccount -ResourceGroupName AZ500LAB03 -Name (Get-Random -Maximum 999999999999999) -Location  EastUS -SkuName Standard_LRS -Kind StorageV2 

# Remove delete lock
$storageaccountname = (Get-AzStorageAccount -ResourceGroupName AZ500LAB03).StorageAccountName

$lockName = (Get-AzResourceLock -ResourceGroupName AZ500LAB03 -ResourceName $storageAccountName -ResourceType Microsoft.Storage/storageAccounts).Name

Remove-AzResourceLock -LockName $lockName -ResourceName $storageAccountName  -ResourceGroupName AZ500LAB03 -ResourceType Microsoft.Storage/storageAccounts -Force

# Check if you are able to create VMs in a given region
az vm list-skus --location 'region' -o table --query "[? contains(name,'Standard_D2s')].name"
