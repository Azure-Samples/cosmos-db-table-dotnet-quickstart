namespace Microsoft.Samples.Cosmos.Table.Quickstart.Models.Settings;

public record Configuration
{
    public required AzureCosmosDB AzureCosmosDB { get; init; }
}

public record AzureCosmosDB
{
    public required string Endpoint { get; init; }

    public required string TableName { get; init; }
}