FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["web/Microsoft.Samples.Cosmos.Table.Quickstart.Web.csproj", "web/"]
COPY ["models/Microsoft.Samples.Cosmos.Table.Quickstart.Models.csproj", "models/"]
COPY ["services/Microsoft.Samples.Cosmos.Table.Quickstart.Services.csproj", "services/"]
COPY ["Microsoft.Samples.Cosmos.Table.Quickstart.sln", "."]
RUN dotnet restore "Microsoft.Samples.Cosmos.Table.Quickstart.sln"
COPY . .
RUN dotnet build "Microsoft.Samples.Cosmos.Table.Quickstart.sln" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "web/Microsoft.Samples.Cosmos.Table.Quickstart.Web.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Microsoft.Samples.Cosmos.Table.Quickstart.Web.dll"]