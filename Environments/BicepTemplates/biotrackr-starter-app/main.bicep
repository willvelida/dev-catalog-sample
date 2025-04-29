@description('The region to deploy all the resources')
param location string = resourceGroup().location

@description('The tags to apply to all resources in this application')
param tags object = {}

@description('The name of the application to deploy')
param appName string

@description('The environment where this app will be deployed to')
param environment string

module logAnalytics 'br/VelocityPlatforms:log-analytics:v1' = {
  name: 'law'
  params: {
    name: '${environment}-${appName}-law'
    location: location
    tags: tags
  }
}

module appInsights 'br/VelocityPlatforms:app-insights:v1' = {
  name: 'appins'
  params: {
    name: '${environment}-${appName}-ains'
    location: location
    tags: tags
    logAnalyticsName: logAnalytics.outputs.logAnalyticsName
  }
}

module uai 'br/VelocityPlatforms:uai:v1' = {
  name: 'uai'
  params: {
    name: '${environment}-${appName}-uai'
    location: location
    tags: tags
  }
}

module appConfig 'br/VelocityPlatforms:app-config:v1' = {
  name: 'app-config'
  params: {
    name: '${environment}-${appName}-config'
    location: location
    tags: tags
    logAnalyticsName: logAnalytics.outputs.logAnalyticsName
    uaiName: uai.outputs.uaiName
  }
}

module keyVault 'br/VelocityPlatforms:key-vault:v1' = {
  name: 'kv'
  params: {
    name: '${environment}-${appName}-kv'
    location: location
    tags: tags
    logAnalyticsName: logAnalytics.outputs.logAnalyticsName
    uaiName: uai.outputs.uaiName
  }
}

module env 'br/VelocityPlatforms:container-app-env:v1' = {
  name: 'env'
  params: {
    name: '${environment}-${appName}-env'
    location: location
    tags: tags
    logAnalyticsName: logAnalytics.outputs.logAnalyticsName
  }
}
module acr 'br/VelocityPlatforms:container-registry:v1' = {
  name: 'acr'
  params: {
    name: '${environment}${appName}acr'
    location: location
    tags: tags
    logAnalyticsName: logAnalytics.outputs.logAnalyticsName
    uaiName: uai.outputs.uaiName
  }
}

module cosmosdb 'br/VelocityPlatforms:cosmos-db:v1' = {
  name: 'cosmos-db'
  params: {
    location: location
    tags: tags
    accountName: '${environment}-${appName}-db' 
    appConfigName: appConfig.outputs.appConfigName
    containerName: 'items'
    databaseName: 'ndcapp1DB'
    logAnalyticsName: logAnalytics.outputs.logAnalyticsName
    uaiName: uai.outputs.uaiName
  }
}
