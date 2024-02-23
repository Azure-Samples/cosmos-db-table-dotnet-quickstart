using Azure.Data.Tables;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Azure.Cosmos;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

if (builder.Environment.IsDevelopment())
{

    var secretClient = new SecretClient(new Uri(builder.Configuration["KEYVAULT_ENDPOINT"]), new DefaultAzureCredential());
    var secretCosmos = await secretClient.GetSecretAsync("cosmosconnectionstring");
    
    builder.Services.AddSingleton<TableServiceClient>((_) =>
    {
        // </create_client>
        return new TableServiceClient(secretCosmos.Value.Value);
    });
}
else
{
    var secretClient = new SecretClient(new Uri(builder.Configuration["KEYVAULT_ENDPOINT"]), new DefaultAzureCredential());
    var secretCosmos = await secretClient.GetSecretAsync("cosmosconnectionstring");
    
    builder.Services.AddSingleton<TableServiceClient>((_) =>
    {
        // </create_client>
        return new TableServiceClient(secretCosmos.Value.Value);
    });
}

builder.Services.AddTransient<ITableService, TableService>();

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
