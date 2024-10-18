using Azure.Data.Tables;
using Azure.Identity;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

builder.Services.AddSingleton<TableServiceClient>((_) =>
{
    // <create_client>
    TableServiceClient serviceClient = new(
        endpoint: new Uri(builder.Configuration["AZURE_COSMOS_DB_TABLE_ENDPOINT"]!),
        tokenCredential: new DefaultAzureCredential()
    );
    // </create_client>

    return serviceClient;
});

builder.Services.AddTransient<IDemoService, DemoService>();

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
