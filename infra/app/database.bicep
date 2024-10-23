metadata description = 'Create database accounts.'

param accountName string
param location string = resourceGroup().location
param tags object = {}

@description('Id of the service principals to assign database and application roles.')
param appPrincipalId string

@description('Id of the user principals to assign database and application roles.')
param userPrincipalId string = ''

module cosmosDbAccount 'br/public:avm/res/document-db/database-account:0.8.0' = {
  name: 'cosmos-db-account'
  params: {
    name: accountName
    location: location
    locations: [
      {
        failoverPriority: 0
        locationName: location
        isZoneRedundant: false
      }
    ]
    tags: tags
    disableKeyBasedMetadataWriteAccess: true
    disableLocalAuth: true
    networkRestrictions: {
      publicNetworkAccess: 'Enabled'
      ipRules: []
      virtualNetworkRules: []
    }
    capabilitiesToAdd: [
      'EnableServerless'
      'EnableTable'
    ]
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
    tables: [
      {
        name: 'cosmicworks-products'
      }
    ]
  }
}

output endpoint string = 'https://${cosmosDbAccount.outputs.name}.table.cosmos.azure.com:443/'
