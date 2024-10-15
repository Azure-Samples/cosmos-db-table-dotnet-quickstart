metadata description = 'Create database accounts.'

param accountName string
param location string = resourceGroup().location
param tags object = {}

@description('Id of the service principals to assign database and application roles.')
param appPrincipalId string

@description('Id of the user principals to assign database and application roles.')
param userPrincipalId string = ''

var table = {
  name: 'cosmicworks-products' // Based on AdventureWorksLT data set
  autoscale: true // Scale at the database level
  throughput: 1000 // Enable autoscale with a minimum of 100 RUs and a maximum of 1,000 RUs
}

module cosmosDbAccount 'br/public:avm/res/document-db/database-account:0.6.1' = {
  name: 'cosmos-db-account'
  params: {
    name: accountName
    location: location
    tags: tags
    capabilitiesToAdd: [
      'EnableTable'
    ]
    disableKeyBasedMetadataWriteAccess: true
    disableLocalAuth: true
    sqlRoleDefinitions: [
      {
        name: 'Write to Azure Cosmos DB for Table data plane'
        dataAction: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata' // Read account metadata
          'Microsoft.DocumentDB/databaseAccounts/tables/*' // Manage tables
          'Microsoft.DocumentDB/databaseAccounts/tables/containers/entities/*' // Create entities          
        ]
      }
    ]
    sqlRoleAssignmentsPrincipalIds: union(
      [
        appPrincipalId
      ],
      !empty(userPrincipalId)
        ? [
            userPrincipalId
          ]
        : []
    )
    /*tables: [
      {
        name: table.name
        autoscale: table.autoscale
        throughput: table.throughput
      }
    ]*/
  }
}

output name string = cosmosDbAccount.outputs.name
output endpoint string = cosmosDbAccount.outputs.endpoint
output tableName string = table.name
