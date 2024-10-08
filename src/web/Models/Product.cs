using Azure;
using Azure.Data.Tables;

namespace Cosmos.Samples.Table.Quickstart.Web.Models;

// <model>
public record Product(
    string name,
    int quantity,
    decimal price,
    bool clearance
) : ITableEntity
{
    public string RowKey { get; set; } = $"{Guid.NewGuid()}";

    public string PartitionKey { get; set; } = String.Empty;

    public ETag ETag { get; set; } = ETag.All;

    public DateTimeOffset? Timestamp { get; set; }
};
// </model>
