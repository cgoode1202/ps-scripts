# Define variables
$resourceGroupName = "static-website-rg"
$location = "westus"
$storageName = "staticwebsitedemo678972"
$storageSku = "Standard_GRS"
$customDomain = "<custom-name-here>"

# Create a resource group
New-AzResourceGroup -Name $ResourceGroupName -location $location

# Create a storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupname -Name $storageName -Location $location -SkuName $storagesku

# Set the current default storage account
Set-AzCurrentStorageAccount -ResourceGroupName $ResourceGroupName -Name $storageName

# Get context of the storage account for next commands
$ctx = $storageAccount.Context

# Enable static website
Enable-AzStorageStaticWebsite -IndexDocument "index.html" -ErrorDocument404Path "index.html"

# Upload a file making sure to set the content type to text/html
set-AzStorageblobcontent -File "index.html" -Container `$web -Blob "index.html" -Context $ctx -Properties @{ ContentType = "text/html; charset=utf-8";}

# Now you have a static website up and running on Azure!
# Use these commands to get the public URL
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageName
Write-Output $storageAccount.PrimaryEndpoints.Web

# Register your customer domain with Azure
Set-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageName -CustomDomainName $customDomain -UseSubDomain $false
