using Azure;
using Azure.Data.Tables;

namespace Microsoft.Samples.Cosmos.Table.Quickstart.Models;

public record Product : ITableEntity
{
    public string RowKey { get; set; } = $"{Guid.NewGuid()}";

    public string PartitionKey { get; set; } = String.Empty;

    public string Name { get; set; } = String.Empty;

    public int Quantity { get; set; } = 0;

    public decimal Price { get; set; } = 0.0m;

    public bool Clearance { get; set; } = false;

    public ETag ETag { get; set; } = ETag.All;

    public DateTimeOffset? Timestamp { get; set; }
};
