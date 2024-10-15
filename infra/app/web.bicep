metadata description = 'Create web application resources.'

param envName string
param appName string
param serviceTag string
param location string = resourceGroup().location
param tags object = {}

@description('Endpoint for Azure Cosmos DB for Table account.')
param databaseAccountEndpoint string

@description('Name of the referenced table.')
param databaseTableName string

module containerAppsEnvironment '../core/host/container-apps/environments/managed.bicep' = {
  name: 'container-apps-env'
  params: {
    name: envName
    location: location
    tags: tags
  }
}

module containerAppsApp '../core/host/container-apps/app.bicep' = {
  name: 'container-apps-app'
  params: {
    name: appName
    parentEnvironmentName: containerAppsEnvironment.outputs.name
    location: location
    tags: union(tags, {
        'azd-service-name': serviceTag
      })
    secrets: [
      {
        name: 'azure-cosmos-db-table-endpoint' // Create a uniquely-named secret
        value: databaseAccountEndpoint // Table database account endpoint
      }
      {
        name: 'azure-cosmos-db-table-name' // Create a uniquely-named secret
        value: databaseTableName // Table name
      }
    ]
    environmentVariables: [
      {
        name: 'AZURE_COSMOS_DB_TABLE_ENDPOINT' // Name of the environment variable referenced in the application
        secretRef: 'azure-cosmos-db-table-endpoint' // Reference to secret
      }
      {
        name: 'AZURE_COSMOS_DB_TABLE_NAME' // Name of the environment variable referenced in the application
        secretRef: 'azure-cosmos-db-table-name' // Reference to secret
      }
    ]
    targetPort: 8080
    enableSystemAssignedManagedIdentity: true
    containerImage: 'mcr.microsoft.com/dotnet/samples:aspnetapp'
  }
}

output endpoint string = containerAppsApp.outputs.endpoint
output envName string = containerAppsApp.outputs.name
output systemAssignedManagedIdentityPrincipalId string =  containerAppsApp.outputs.systemAssignedManagedIdentityPrincipalId
