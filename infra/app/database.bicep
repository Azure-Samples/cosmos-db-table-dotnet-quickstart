metadata description = 'Create database accounts.'

param accountName string
param location string = resourceGroup().location
param tags object = {}

@description('Id of the service principals to assign database and application roles.')
param appPrincipalId string

@description('Id of the user principals to assign database and application roles.')
param userPrincipalId string = ''

module cosmosDbAccount 'br/public:avm/res/document-db/database-account:0.6.1' = {
  name: 'cosmos-db-account'
  params: {
    name: accountName
    location: location
    tags: tags
    capabilitiesToAdd: [
      'EnableTable'
    ]
    disableLocalAuth: true
    sqlRoleDefinitions: [
      {
        name: 'table-data-plane-contributor'
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
  }
}

resource account 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: accountName
}

resource table 'Microsoft.DocumentDB/databaseAccounts/tables@2023-04-15' = {
  name: 'cosmicworks-products'
  dependsOn: [
    cosmosDbAccount // Create an artifical wait for the account to be created
  ]
  parent: account
  tags: tags
  properties: {
    options: {
      autoscaleSettings: {
        maxThroughput: 1000
      }
    } 
    resource: {
      id: 'cosmicworks-products'
    }
  }
}

output name string = cosmosDbAccount.outputs.name
output endpoint string = cosmosDbAccount.outputs.endpoint
output tableName string = table.name
