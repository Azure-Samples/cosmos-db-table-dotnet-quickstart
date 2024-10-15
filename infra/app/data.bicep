metadata description = 'Create database account resources.'

param databaseAccountName string
param tags object = {}

var table = {
  name: 'cosmicworks-products' // Based on AdventureWorksLT data set
  autoscale: true // Scale at the database level
  throughput: 1000 // Enable autoscale with a minimum of 100 RUs and a maximum of 1,000 RUs
}

module cosmosDbTable '../core/database/cosmos-db/table/table.bicep' = {
  name: 'cosmos-db-table-${table.name}'
  params: {
    name: table.name
    parentAccountName: databaseAccountName
    tags: tags
    setThroughput: true
    autoscale: table.autoscale
    throughput: table.throughput
  }
}

output table object = {
  name: cosmosDbTable.outputs.name
}
