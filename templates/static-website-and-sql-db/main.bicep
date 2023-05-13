@description('The location into which your Azure resources should be deployed.')
param location string = resourceGroup().location

@description('Select the type of environment you want to provision. Allowed values and Production and Test.')
@allowed([
  'Production'
  'Test'
])
param environmentType string

param resourceNameSuffix string = uniqueString(resourceGroup().id)

@minValue(1)
param skuCapacity int = 1

@description('The administrator login username for the SQL server.')
param sqlAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlAdministratorLoginPassword string

@description('This is role definition ID of the built-in Azure \'Contributor\' role.')
param contributorRoleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

param storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
param container1Name string = 'productspecs'
param productManualsName string = 'productmanuals'


// Define the names for resources
var appServiceAppName = 'webSite${resourceNameSuffix}'
var appServicePlanName = 'AppServicePlan'
var sqlServerName = 'sqlserver${resourceNameSuffix}'
var sqlDatabaseName = 'ToyCompanyWebsite'
var storageAccountName = 'toywebsite${resourceNameSuffix}'
var managedIdentityName = 'WebSite'
var applicationInsightsName = 'AppInsights'

@description('Define the SKUs for each component based on the environment type.')
var environmentConfigurationMap = {
  Production: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_GRS'
      }
    }
    sqlDatabase: {
      sku: {
        name: 'S1'
        tier: 'Standard'
      }
    }
  }
  Test: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
    sqlDatabase: {
      sku: {
        name: 'Basic'
      }
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

  resource blobServices 'blobServices' existing = {
    name: 'default'
  }
}

resource container1 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  parent: storageAccount::blobServices
  name: container1Name
}

resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}


resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource sqlFirewallRuleAllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource productmanuals 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${storageAccount.name}/default/${productManualsName}'
}
resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServiceAppName
  location: location
  sku: {
    name: hostingPlanSkuName
    capacity: skuCapacity
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlanName.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: storageAccountConnectionString
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {} // This format is required when working with managed identities.
    }
  }
}

@description('A user-assigned managed identity that is used by the App Service app to communicate with a storage account.')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

@description('Grant the Contributor role to the user-assigned managed identity, at the scope of the resource group.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(contributorRoleDefinitionId, resourceGroup().id)

  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalId: managedIdentity.properties.principalId
    description: 'Grant the "Contributor role to the user-assigned managed identity so it can access the storage account.'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: 'AppInsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
