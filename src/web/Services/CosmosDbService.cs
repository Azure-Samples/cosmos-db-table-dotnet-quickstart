using Cosmos.Samples.Table.Quickstart.Web.Models;
using Azure.Data.Tables;

internal interface ITableService
{
    Task RunDemoAsync(Func<string, Task> writeOutputAync);

    string GetEndpoint();
}

internal sealed class TableService : ITableService
{
    private readonly TableServiceClient client;

    public TableService(TableServiceClient client)
    {
        this.client = client;
    }

    public string GetEndpoint() => $"{client.Uri.AbsoluteUri}";

    public async Task RunDemoAsync(Func<string, Task> writeOutputAync)
    {
        // <get_table>
       // New instance of TableClient class referencing the server-side table
        TableClient tableClient = client.GetTableClient(
            tableName: "products"
        );

        await tableClient.CreateIfNotExistsAsync();
        await writeOutputAync($"Get table:\t{tableClient.Name}");
        // </get_table>
        
        // <create_object_add> 

        // Create new item using composite key constructor
        var key = new Random().Next(1000000, 9999999).ToString();
        var prod1 = new Product()
        {
            RowKey = key,
            PartitionKey = "gear-surf-surfboards",
            Name = "Ocean Surfboard",
            Quantity = 8,
            Sale = true
        };

        // Add new item to server-side table
        var response = await tableClient.AddEntityAsync<Product>(prod1);
        // </create_object_add>            

        // <read_item> 
        // Read a single item from container
        var product = await tableClient.GetEntityAsync<Product>(
            rowKey: key, // prevent duplicates
            partitionKey: "gear-surf-surfboards"
        );            
        await writeOutputAync($"Upserted item:\t{product.Value.Name}");
        await writeOutputAync($"Status code:\t{product.GetRawResponse().Status}");
        // </read_item>

        // <query_items> 
        // Read multiple items from container
        var key2 = new Random().Next(1000000, 9999999).ToString();
        var prod2 = new Product()
        {
            RowKey = key2,
            PartitionKey = "gear-surf-surfboards",
            Name = "Sand Surfboard",
            Quantity = 5,
            Sale = false
        };

        await tableClient.AddEntityAsync<Product>(prod2);

        var products = tableClient.Query<Product>(x => x.PartitionKey == "gear-surf-surfboards");

        await writeOutputAync("Get multiple products:");
        foreach (var item in products)
        {
            await writeOutputAync(item.Name);
        }
        // </query_items>
    }
}
