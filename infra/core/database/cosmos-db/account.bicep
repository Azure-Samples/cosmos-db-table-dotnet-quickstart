metadata description = 'Create an Azure Cosmos DB account.'

param name string
param location string = resourceGroup().location
param tags object = {}

@allowed([ 'GlobalDocumentDB', 'MongoDB', 'Parse' ])
@description('Sets the kind of account.')
param kind string

// @description('Enables serverless for this account. Defaults to false.')
// param enableServerless bool = false

@description('Disables key-based authentication. Defaults to false.')
param disableKeyBasedAuth bool = false

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: toLower(name)
  location: location
  kind: kind
  properties: {
    capabilities: [
      {
        name: 'EnableTable'
      }
    ]
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    disableLocalAuth: disableKeyBasedAuth
  }
  tags: tags
}

output endpoint string = account.properties.documentEndpoint
output name string = account.name
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${account.name};AccountKey=${account.listKeys().primaryMasterKey};TableEndpoint=https://${account.name}.table.cosmos.azure.com:443/;'
