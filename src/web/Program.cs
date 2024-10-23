using Azure.Data.Tables;
using Azure.Identity;
using Microsoft.Samples.Cosmos.Table.Quickstart.Services;
using Microsoft.Samples.Cosmos.Table.Quickstart.Services.Interfaces;
using Microsoft.Samples.Cosmos.Table.Quickstart.Web.Components;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents().AddInteractiveServerComponents();

builder.Services.AddSingleton<TableServiceClient>((_) =>
{
    // <create_client>
    TableServiceClient client = new(
        endpoint: new Uri(builder.Configuration["AZURE_COSMOS_DB_TABLE_ENDPOINT"]!),
        tokenCredential: new DefaultAzureCredential()
    );
    // </create_client>
    return client;
});

builder.Services.AddTransient<IDemoService, DemoService>();

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.UseHttpsRedirection();

app.UseAntiforgery();

app.MapStaticAssets();

app.MapRazorComponents<App>().AddInteractiveServerRenderMode();

app.Run();
