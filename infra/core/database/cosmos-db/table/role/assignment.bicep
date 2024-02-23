metadata description = 'Create an Azure Cosmos DB for NoSQL role assignment.'

@description('Name of the target Azure Cosmos DB account.')
param targetAccountName string

@description('Id of the role definition to assign to the targeted principal and account.')
param roleDefinitionId string

@description('Id of the principal to assign the role definition for the account.')
param principalId string

resource account 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: targetAccountName
}

resource assignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(subscription().id, resourceGroup().id, principalId, roleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
  }
}

output id string = assignment.id
