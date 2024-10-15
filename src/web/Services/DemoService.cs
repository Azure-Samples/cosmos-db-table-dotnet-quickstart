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
            Product entity = new()
            {
                RowKey = "68719518391",
                PartitionKey = "gear-surf-surfboards",
                Name = "Surfboard",
                Quantity = 10,
                Price = 300.00m,
                Clearance = true
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
            Product entity = new()
            {
                RowKey = "68719518371",
                PartitionKey = "gear-surf-surfboards",
                Name = "Kiama Classic Surfboard",
                Quantity = 25,
                Price = 790.00m,
                Clearance = false
            };


            Response response = await client.UpsertEntityAsync<Product>(
                entity: entity,
                mode: TableUpdateMode.Replace
            );
            await writeOutputAync($"Upserted entity:\t{entity}");
            await writeOutputAync($"Status code:\t{response.Status}");
        }

        {
            // <read_entity>
            Response<Product> response = await client.GetEntityAsync<Product>(
                rowKey: "68719518391",
                partitionKey: "gear-surf-surfboards"
            );
            // </read_entity>
            await writeOutputAync($"Read entity row key:\t{response.Value.RowKey}");
            await writeOutputAync($"Read entity:\t{response.Value}");
            await writeOutputAync($"Status code:\t{response.GetRawResponse().Status}");
        }

        {
            // <query_entities>
            string category = "gear-surf-surfboards";
            AsyncPageable<Product> results = client.QueryAsync<Product>(
                product => product.PartitionKey == category
            );
            // </query_entities>
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
                await writeOutputAync($"Found entity:\t{entity.Name}\t[{entity.RowKey}]");
            }
        }
    }
}
