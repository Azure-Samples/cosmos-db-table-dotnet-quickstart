namespace Microsoft.Samples.Cosmos.Table.Quickstart.Services.Interfaces;

public interface IDemoService
{
    Task RunAsync(Func<string, Task> writeOutputAync);

    string GetEndpoint();
}