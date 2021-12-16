targetScope = 'subscription'

param rgName string

param location string

param name string

@description('MySQL server password')
@secure()
param databasePassword string

var databaseLogin = 'mysqlSecure'
var logAnalyticsWorkspaceName = '${name}-logAnalytics'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module logAnalyticsWorkspace './modules/createLogAnalytics.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${name}-log-analytics'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceSku: 'Free' 
  }
}

module mySQLServer 'modules/createMySQLdb.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${name}-mysql'
  params: {
    administratorLogin: databaseLogin
    administratorPassword: databasePassword
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
    mySQLServerName: '${name}-mysql-2020'
    mySQLServerSku: 'B_Gen5_1' 
  }
}

module appservicePlan 'modules/createAppServicePlan.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${name}-asp'
  params: {
    appServicePlanName: name
    appServicePlanSku: 'B1'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module webApp 'modules/createWebApp.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${name}-webapp'
  params: {
    administratorPassword: databasePassword
    appServicePlanId: appservicePlan.outputs.id
    deploymentConfiguration: 'Web app with Azure CDN'
    ghostContainerImage: 'jldeen/ghost:latest'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
    webAppName: name
  }
}
