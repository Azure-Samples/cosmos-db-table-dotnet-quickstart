---
page_type: sample
name: "Quickstart: Azure Cosmos DB for Table and Azure SDK for .NET"
description: This is a simple ASP.NET web application to illustrate common basic usage of Azure Cosmos DB for Table and the Azure SDK for .NET.
urlFragment: template
languages:
- csharp
- azdeveloper
products:
- azure-cosmos-db
---

# Quickstart: Azure Cosmos DB for Table client library for .NET

This is a simple Blazor web application to illustrate common basic usage of Azure Cosmos DB for Table's client library for .NET. This sample application accesses an existing account and tables using the [`Azure.Data.Tables`](https://www.nuget.org/packages/Azure.Data.Tables) and  [`Azure.Identity`](https://www.nuget.org/packages/Azure.Identity) libraries from NuGet.

### Prerequisites

- [Docker](https://www.docker.com/)
- [Azure Developer CLI](https://aka.ms/azd-install)
- [.NET SDK 8.0](https://dotnet.microsoft.com/download/dotnet/8.0) 

### Quickstart

1. Log in to Azure Developer CLI.

    ```bash
    azd auth login
    ```

    > [!TIP]
    > This is only required once per-install.

1. Initialize this template (`cosmos-db-table-dotnet-quickstart`) using `azd init`

    ```bash
    azd init --template cosmos-db-table-dotnet-quickstart
    ```

1. Ensure that **Docker** is running in your environment.

1. Use `azd up` to provision your Azure infrastructure and deploy the web application to Azure.

    ```bash
    azd up
    ```

1. Observed the deployed web application

    ![Screenshot of the deployed web application.](assets/web.png)

1. (Optionally) Run this web application locally in the `src/web` folder: 

    ```dotnetcli
    dotnet watch run
    ```

    > [!IMPORTANT]
    > When your Azure infrastructure is provisioned, the endpoint for your deployed Azure Cosmos DB for Table account is automatically saved in the .NET user secrets store to make debugging easier. For more information, see [safe storage of app secrets in development](https://learn.microsoft.com/aspnet/core/security/app-secrets).
