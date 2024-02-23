targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention.')
param environmentName string

@minLength(1)
@description('Primary location for all resources.')
param location string

@description('Id of the principal to assign database and application roles.')
param principalId string = ''

// Optional parameters
param cosmosDbAccountName string = ''
param containerRegistryName string = ''
param containerAppsEnvName string = ''
param containerAppsAppName string = ''
param userAssignedIdentityName string = ''
param kvName string = ''

// serviceName is used as value for the tag (azd-service-name) azd uses to identify deployment host
param serviceName string = 'web'

var abbreviations = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  repo: 'https://github.com/azure-samples/cosmos-db-table-dotnet-quickstart'
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: environmentName
  location: location
  tags: tags
}

module kv 'core/security/keyvault/keyvault.bicep' = {
  name: 'kv'
  scope: resourceGroup
  params: {
    name: !empty(kvName) ? kvName : '${abbreviations.keyVault}-${resourceToken}'
    location: location
    tags: tags
    principalId: principalId
  }
}

module kvSecret 'core/security/keyvault/keyvault-secret.bicep' = {
  name: 'kvSecret'
  scope: resourceGroup
  params: {
    keyVaultName: kv.outputs.name
    name: 'cosmosconnectionstring'
    secretValue: account.outputs.connectionString
  }
}

// Give the API access to KeyVault
module apiKeyVaultAccess 'core/security/keyvault/keyvault-access.bicep' = {
  name: 'api-keyvault-access'
  scope: resourceGroup
  params: {
    keyVaultName: kv.outputs.name
    principalId: identity.outputs.principalId
  }
}

// Give the User access to KeyVault
module userKeyVaultAccess 'core/security/keyvault/keyvault-access.bicep' = {
  name: 'user-keyvault-access'
  scope: resourceGroup
  params: {
    keyVaultName: kv.outputs.name
    principalId: principalId
  }
}

module identity 'app/identity.bicep' = {
  name: 'identity'
  scope: resourceGroup
  params: {
    identityName: !empty(userAssignedIdentityName) ? userAssignedIdentityName : '${abbreviations.userAssignedIdentity}-${resourceToken}'
    location: location
    tags: tags
  }
}

module account 'app/account.bicep' = {
  name: 'account'
  scope: resourceGroup
  params: {
    accountName: !empty(cosmosDbAccountName) ? cosmosDbAccountName : '${abbreviations.cosmosDbAccount}-${resourceToken}'
    location: location
    tags: tags
  }
}

module data 'app/data.bicep' = {
  name: 'data'
  scope: resourceGroup
  params: {
    databaseAccountName: account.outputs.accountName
    tags: tags
  }
}

module registry 'app/registry.bicep' = {
  name: 'registry'
  scope: resourceGroup
  params: {
    registryName: !empty(containerRegistryName) ? containerRegistryName : '${abbreviations.containerRegistry}${resourceToken}'
    location: location
    tags: tags
  }
}

module web 'app/web.bicep' = {
  name: serviceName
  scope: resourceGroup
  params: {
    envName: !empty(containerAppsEnvName) ? containerAppsEnvName : '${abbreviations.containerAppsEnv}-${resourceToken}'
    appName: !empty(containerAppsAppName) ? containerAppsAppName : '${abbreviations.containerAppsApp}-${resourceToken}'
    databaseAccountEndpoint: account.outputs.endpoint
    userAssignedManagedIdentity: {
      resourceId: identity.outputs.resourceId
      clientId: identity.outputs.clientId
    }
    location: location
    tags: tags
    serviceTag: serviceName
    keyVaultEndpoint: kv.outputs.endpoint
  }
}

// Database outputs
output AZURE_COSMOS_ENDPOINT string = account.outputs.endpoint
output AZURE_COSMOS_TABLE_NAMES array = map(data.outputs.tables, c => c.name)

// Container outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = registry.outputs.endpoint
output AZURE_CONTAINER_REGISTRY_NAME string = registry.outputs.name

// Application outputs
output AZURE_CONTAINER_APP_ENDPOINT string = web.outputs.endpoint
output AZURE_CONTAINER_ENVIRONMENT_NAME string = web.outputs.envName

// Identity outputs
output AZURE_USER_ASSIGNED_IDENTITY_NAME string = identity.outputs.name

// Security outputs
output KEYVAULT_ENDPOINT string = kv.outputs.endpoint
