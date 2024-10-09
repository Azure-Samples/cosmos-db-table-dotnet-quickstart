metadata description = 'Create an Azure Cosmos DB for Table role definition.'

@description('Name of the target Azure Cosmos DB account.')
param targetAccountName string

@description('Name of the role definiton.')
param definitionName string

@description('An array of data actions that are allowed. Defaults to an empty array.')
param permissionsDataActions string[] = []

resource account 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: targetAccountName
}

resource definition 'Microsoft.DocumentDB/databaseAccounts/tableRoleDefinitions@2023-04-15' = {
  name: guid('table-role-definition', account.id)
  parent: account
  properties: {
    assignableScopes: [
      account.id
    ]
    permissions: [
      {
        dataActions: permissionsDataActions
      }
    ]
    roleName: definitionName
    type: 'CustomRole'
  }
}

output id string = definition.id
