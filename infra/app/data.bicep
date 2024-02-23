metadata description = 'Create database account resources.'

param databaseAccountName string
param tags object = {}

var database = {
  name: 'cosmicworks' // Based on AdventureWorksLT data set
  autoscale: true // Scale at the database level
  throughput: 1000 // Enable autoscale with a minimum of 100 RUs and a maximum of 1,000 RUs
}

var tableNames = [
  {
    name: 'products' // Set of products
  }
]

module cosmosDbTables '../core/database/cosmos-db/table/table.bicep' = [for (table, _) in tableNames: {
  name: 'cosmos-db-table-${table.name}'
  params: {
    name: table.name
    parentAccountName: databaseAccountName
    tags: tags
    setThroughput: false
    autoscale: database.autoscale
    throughput: database.throughput
  }
}]

output tables array = [for (_, index) in tableNames: {
  name: cosmosDbTables[index].outputs.name
}]
