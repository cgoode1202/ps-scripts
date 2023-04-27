# List all resource groups created
Get-AzResourceGroup -Name '[RESOURCE GROUP NAME]*'

# Delete all resource groups
Get-AzResourceGroup -Name '[RESOURCE GROUP NAME]*' | Remove-AzResourceGroup -Force -AsJob

# The command executes asynchronously (as determined by the -AsJob parameter), so while you will 
# be able to run another PowerShell command immediately afterwards within the same PowerShell session, 
# it will take a few minutes before the resource groups are actually removed.

# List all resources in a resource group
Get-AzResource -ResourceGroupName $vm.ResourceGroupName | Format-Table