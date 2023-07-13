FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get -y install nodejs

COPY . ./
RUN dotnet restore && \
    dotnet build "dotnet6.csproj" -c Release && \
    dotnet publish "dotnet6.csproj" -c Release -o publish

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS http://*:9000

RUN groupadd -r chandu && \
    useradd -r -g chandu -s /bin/false chandu && \
    chown -R chandu:chandu /app

USER chandu

EXPOSE 9000
ENTRYPOINT ["dotnet", "dotnet6.dll"]