using Azure;
using Azure.Data.Tables;
using Azure.Data.Tables.Models;
using Cosmos.Samples.Table.Quickstart.Web.Models;

internal interface IDemoService
{
    Task RunAsync(Func<string, Task> writeOutputAync);

    string GetEndpoint();
}

internal sealed class DemoService(TableClient client) : IDemoService
{
    public string GetEndpoint() => $"{client.Uri.AbsoluteUri}";

    public async Task RunAsync(Func<string, Task> writeOutputAync)
    {
        await writeOutputAync($"Get table:\t{client.Name}");

        {
            // <create_entity>
            Product entity = new(
                name: "Yamba Surfboard",
                quantity: 12,
                price: 850.00m,
                clearance: false
            )
            {
                RowKey = "68719518391",
                PartitionKey = "gear-surf-surfboards",
            };

            Response response = await client.UpsertEntityAsync<Product>(
                entity: entity,
                mode: TableUpdateMode.Replace
            );
            // </create_entity>
            await writeOutputAync($"Upserted entity:\t{entity}");
            await writeOutputAync($"Status code:\t{response.Status}");
        }

        {
            Product entity = new(
                name: "Kiama Classic Surfboard",
                quantity: 25,
                price: 790.00m,
                clearance: false
            )
            {
                RowKey = "68719518371",
                PartitionKey = "gear-surf-surfboards"
            };


            Response response = await client.UpsertEntityAsync<Product>(
                entity: entity,
                mode: TableUpdateMode.Replace
            );
            await writeOutputAync($"Upserted entity:\t{entity}");
            await writeOutputAync($"Status code:\t{response.Status}");
        }

        {
            // <read_item>
            Response<Product> response = await client.GetEntityAsync<Product>(
                rowKey: "68719518391",
                partitionKey: "gear-surf-surfboards"
            );
            // </read_item>
            await writeOutputAync($"Read entity row key:\t{response.Value.RowKey}");
            await writeOutputAync($"Read entity:\t{response.Value}");
            await writeOutputAync($"Status code:\t{response.GetRawResponse().Status}");
        }

        {
            // <query_items>
            string category = "gear-surf-surfboards";
            AsyncPageable<Product> results = client.QueryAsync<Product>(
                product => product.PartitionKey == category
            );
            // </query_items>
            await writeOutputAync($"Ran query");

            // <parse_results>
            List<Product> entities = new();
            await foreach (Product product in results)
            {
                entities.Add(product);
            }
            // </parse_results>

            foreach (var entity in entities)
            {
                await writeOutputAync($"Found entity:\t{entity.name}\t[{entity.RowKey}]");
            }
        }
    }
}
