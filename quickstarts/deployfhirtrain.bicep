// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//
// Healthcare APIs (API for FHIR) : Training starter template
// 

@description('Tags to be applied to resources that are deployed in this template')
param resourceTags object  = {
  environmentName: 'Azure Healthcare APIs OpenHack'
  challengeTitle: 'Deploy Core Training Environment'
  eventId: '6071'
  expirationDate: '03/30/2022'
}
@description('Deployment Prefix - all resources names created by this template will start with this prefix')
@minLength(3)
@maxLength(7)
param deploymentPrefix string

@description('FHIR Server Azure AD Tenant ID (GUID)')
param fhirServerTenantName string = subscription().tenantId

@description('Azure Region where the resources will be deployed. Default Value:  the resource group region')
param resourceLocation string = resourceGroup().location

@description('Enable the Consent Opt Out module in FHIR PROXY')
param enableConsentOptOut bool = false

@description('Enable the Date Sort module in FHIR PROXY')
param enableDateSort bool = false

@description('Enable the Participant Filter module in FHIR PROXY')
param enableParticipantFilter bool = false

@description('Enable the FHIR to CDS Sync Agent module in FHIR PROXY')
param enableFhirCdsSyncAgent bool = false

@description('Enable the Pubish FHIR Event module in FHIR PROXY')
param enablePublishFhirEvent bool = false

@description('Enable the Profile Validation module in FHIR PROXY')
param enableProfileValidation bool = false
@description('Enable the Transform Bundle module in FHIR PROXY')
param enableTransformBundle bool = true
@description('Enable the Patient Everything module in FHIR PROXY')
param enableEverythingPatient bool = false


var tenantId = subscription().tenantId
// Unique Id used to generate resource names
var uniqueId  = take(uniqueString(subscription().id, resourceGroup().id, toLower(deploymentPrefix)),6)

// Default resource names

// Azure key Vault
var kvName   = '${deploymentPrefix}${uniqueId}kv'

// Log Analytics Workspace
var laName   = '${deploymentPrefix}${uniqueId}la'

// API for FHIR Service Name
var apiForFhirServiceName = '${deploymentPrefix}${uniqueId}fhir'

// API for FHIR export and import storage account name
var saName   = '${deploymentPrefix}${uniqueId}fssa'
// API for FHIR artifact container registry name
var containerRegistryName   = '${deploymentPrefix}${uniqueId}cr'

// Azure Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: laName
  location: resourceLocation
  tags: resourceTags
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}
resource logAnalyticsWorkspaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: logAnalyticsWorkspace
  name: 'diagnosticSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'Audit'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}
// create export storage account
resource exportStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: saName
  location: resourceLocation
  tags: resourceTags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    isHnsEnabled: true
    isNfsV3Enabled: false
    minimumTlsVersion: 'TLS1_2'
  }
}
// Blob Services for Storage Account
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name: '${exportStorageAccount.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}
resource bundleContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${exportStorageAccount.name}/default/bundles'
  properties: {
  }
}
resource ndjsonContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${exportStorageAccount.name}/default/ndjson'
  properties: {
  }
}
resource zipContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${exportStorageAccount.name}/default/zip'
  properties: {
  }
}
resource exportContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${exportStorageAccount.name}/default/export'
  properties: {
  }
}
resource exportTriggerContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${exportStorageAccount.name}/default/export-trigger'
  properties: {
  }
}
resource anonymizationTriggerContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${exportStorageAccount.name}/default/anonymization'
  properties: {
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2021-06-01' = {
  name: '${exportStorageAccount.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}
resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-06-01' = {
  name: '${exportStorageAccount.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}
resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-06-01' = {
  name: '${exportStorageAccount.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

// enable diagnostics for export storage account
resource exportSADiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: exportStorageAccount
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource exportSABlobDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: blobServices
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource exportSAFileDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: fileServices
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource exportSATableDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: tableServices
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource exportSAQueueDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: queueServices
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}

// Azure Container Registry
resource artifactContainerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name:containerRegistryName
  tags: resourceTags
  location: resourceLocation
  sku: {
    name: 'Basic'
  }
}
// enable diagnostics for container registry
resource artifactContainerRegistryDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: artifactContainerRegistry
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
// Azure Key Vault 
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' =  {
  name: kvName
  location: resourceLocation
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    softDeleteRetentionInDays: 7
    enableSoftDelete: true
    enableRbacAuthorization: false
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}
// enable diagnostic settings for KV
resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
// API for FHIR Resource
var systemIdentity = {
  type: 'SystemAssigned'
}
resource apiForFhir 'Microsoft.HealthcareApis/services@2021-06-01-preview' ={
  name: apiForFhirServiceName
  tags: resourceTags
  kind: 'fhir-R4'
  location: resourceLocation
  identity: systemIdentity
  properties:{
    authenticationConfiguration: {
      audience: 'https://${apiForFhirServiceName}.azurehealthcareapis.com'
      authority: uri(environment().authentication.loginEndpoint,subscription().tenantId)
    }
    exportConfiguration:{
      storageAccountName: exportStorageAccount.name
    }
    acrConfiguration:{
      loginServers: [
        // to be updated
        '${artifactContainerRegistry.name}.azurecr.io'
      ]
    }
  }
}
// enable diagnostic settings for API for FHIR
resource fhirDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apiForFhir
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}

// FHIR Service parameters that are saved to KV
resource fhirServerUrlSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' =  {
  name: '${keyVault.name}/fhirServiceUrl'
  properties:{
    value: 'https://${apiForFhirServiceName}.azurehealthcareapis.com'
  }
}
resource fhirServerTenantNameSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = if(!empty(fhirServerTenantName)) {
  name: '${keyVault.name}/fhirServiceTenantName'
  properties:{
    value: fhirServerTenantName
  }
}
resource logAnalyticsWorkspacenameSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/logAnalyticsWorkspaceName'
  properties:{
    value: logAnalyticsWorkspace.name
  }
}

// Assign API for  FHIR service Permissions to Storage Account
module functionsStoragePermissions './assignpermissions.bicep' = {
  name: 'proxyFHIRPermissions'
  params: {
    principalId: apiForFhir.identity.principalId
    builtInRoleType: 'StorageBlobDataContributor'
    resourceType: 'Storage'
    resourceName: functionsStorageAccount.name
  }
}
module registryPermissions './assignpermissions.bicep' = {
  name: 'registryPermissions'
  params: {
    principalId: apiForFhir.identity.principalId
    builtInRoleType: 'AcrPull'
    resourceType: 'Registry'
    resourceName: artifactContainerRegistry.name
  }
}

//
// Healthcare APIs (API for FHIR) : Training starter FHIR Loader and Proxy
// 


// FHIR Loader and Proxy resource names
var proxyStorageAccountName = '${deploymentPrefix}${uniqueId}funsa'
var proxyFunctionAppName    = '${deploymentPrefix}${uniqueId}pxyfa'
var loaderFunctionAppName   = '${deploymentPrefix}${uniqueId}ldrfa'
var redisCacheName          = '${deploymentPrefix}${uniqueId}rc'
var appServicePlanName      = '${deploymentPrefix}${uniqueId}asp'
var proxyAppInsightName     = '${deploymentPrefix}${uniqueId}pxyai'
var loaderAppInsightName    = '${deploymentPrefix}${uniqueId}ldrai'
var loaderEventGridTopicName = '${deploymentPrefix}${uniqueId}ldrtopic'

// FHIR Proxy Code Repo
var fhirProxyRepoUrl = 'https://github.com/ToddM2/fhir-proxy'
var fhirProxyRepoBranch = 'MSIOnly'
// FHIR Bulk Loader Code Repo
var fhirLoaderRepoUrl = 'https://github.com/ToddM2/fhir-loader'
var fhirLoaderRepoBranch = 'MSIOnly'


// create a storage account for FHIR Loader/Proxy and enable diagnostic logging
resource functionsStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: proxyStorageAccountName
  location: resourceLocation
  tags: resourceTags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    isHnsEnabled: false
    isNfsV3Enabled: false
    minimumTlsVersion: 'TLS1_2'
  }
}
resource functionsBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name: '${functionsStorageAccount.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}
resource functionsFileServices 'Microsoft.Storage/storageAccounts/fileServices@2021-06-01' = {
  name: '${functionsStorageAccount.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}
resource functionsQueueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-06-01' = {
  name: '${functionsStorageAccount.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}
resource functionsTableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-06-01' = {
  name: '${functionsStorageAccount.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}
resource storageAcountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: functionsStorageAccount
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource functionsStorageAccountBlobDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: functionsBlobServices
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource functionsStorageAccountFileDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: functionsFileServices
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource functionsStorageAccountTableDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: functionsTableServices
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource functionsStorageAccountQueueDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: functionsQueueServices
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
// Azure Redis Cache & diagnostics logging
resource redisCache 'Microsoft.Cache/redis@2020-06-01' = {
  name: redisCacheName
  location: resourceLocation
  tags: resourceTags
  properties: {
    minimumTlsVersion: '1.2'
    sku: {
      family: 'C'
      name: 'Basic'
      capacity: 0
    }
  }
}
resource redisCacheDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: redisCache
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
// App Service Plan for FHIR Bulk Loader and FHIR Proxy
resource appServicePlan 'Microsoft.Web/serverfarms@2020-09-01' = {
  name: appServicePlanName
  location: resourceLocation
  tags: resourceTags
  sku: {
    name: 'S1'
  }
  kind: 'functionapp'
}
resource appServicePlanDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appServicePlan
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [ 
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
// FHIR Proxy Function App
resource fhirProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: proxyFunctionAppName
  location: resourceLocation
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    enabled: true
    httpsOnly: true
    clientAffinityEnabled: false
    serverFarmId: appServicePlan.id
    siteConfig: {
      use32BitWorkerProcess: false
      alwaysOn: true
      ftpsState:'FtpsOnly'
      minTlsVersion: '1.2'
    }
  }
}
resource fhirProxyFunctionAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: fhirProxyFunctionApp
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [ 
      {
        category: 'FunctionAppLogs'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
// FHIR Bulk Loader Function App
resource fhirLoaderFunctionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: loaderFunctionAppName
  location: resourceLocation
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    enabled: true
    httpsOnly: true
    clientAffinityEnabled: false
    serverFarmId: appServicePlan.id
    siteConfig: {
      use32BitWorkerProcess: false
      alwaysOn: true
      ftpsState:'FtpsOnly'
      minTlsVersion: '1.2'
    }
  }
}
resource fhirLoaderFunctionAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: fhirLoaderFunctionApp
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [ 
      {
        category: 'FunctionAppLogs'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}

// Assign Loader and Proxy permissions to API for  FHIR service
module loaderPermissionsFHIRWriter './assignpermissions.bicep' = {
  name: 'loaderPermissionsFHIRWriter'
  params: {
    principalId: fhirLoaderFunctionApp.identity.principalId
    builtInRoleType: 'FHIRDataWriter'
    resourceType: 'FHIR'
    resourceName: apiForFhir.name
  }
}
module proxyPermissionsFHIRContributor './assignpermissions.bicep' = {
  name: 'proxyPermissionsFHIRContributor'
  params: {
    principalId: fhirProxyFunctionApp.identity.principalId
    builtInRoleType: 'FHIRDataContributor'
    resourceType: 'FHIR'
    resourceName: apiForFhir.name
  }
}
module proxyPermissionsFHIRWriter './assignpermissions.bicep' = {
  name: 'proxyPermissionsFHIRWriter'
  params: {
    principalId: fhirProxyFunctionApp.identity.principalId
    builtInRoleType: 'FHIRDataWriter'
    resourceType: 'FHIR'
    resourceName: apiForFhir.name
  }
}


//  save secrets redis and storage account connection string
resource createKeyVaultRedisSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/proxyRedisConnectionString'
  properties:{
    value: '${redisCache.properties.hostName}:${redisCache.properties.sslPort},password=${listKeys(redisCache.id, redisCache.apiVersion).primaryKey},ssl=True,abortConnect=False' 
  }
}
resource functionsStorageAccountConnectionSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/functionsStorageAccountConnectionString'
  properties:{
    value: 'DefaultEndpointsProtocol=https;AccountName=${functionsStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(functionsStorageAccount.id, functionsStorageAccount.apiVersion).keys[0].value}'
  }
}
// FHIR loader and Proxy Application Insights instances
resource proxyAppInsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: proxyAppInsightName
  location: resourceLocation
  kind: 'web'
  tags: resourceTags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
resource loaderAppInsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: loaderAppInsightName
  location: resourceLocation
  kind: 'web'
  tags: resourceTags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
resource proxyAppInsightsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: proxyAppInsights
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}
resource loaderAppInsightsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: loaderAppInsights
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}

// function app settings
var keyVaultUri = keyVault.properties.vaultUri 
var profileValidationString = (enableProfileValidation) ? 'FHIRProxy.preprocessors.ProfileValidationPreProcess;' : '' 
var transformBundleString = (enableTransformBundle) ? 'FHIRProxy.preprocessors.TransformBundlePreProcess;' : ''
var everythingPatientString = (enableEverythingPatient) ? 'FHIRProxy.preprocessors.EverythingPatientPreProcess;' : ''

var proxyPreProcessSettings  = '${profileValidationString}${transformBundleString}${everythingPatientString}' 
var fhirProxyPreProcess = take(proxyPreProcessSettings, length(proxyPreProcessSettings)-1)

var consentOptOutString = (enableConsentOptOut) ? 'FHIRProxy.postprocessors.ConsentOptOutFilter;' : ''
var dateSortString  = (enableDateSort) ? 'FHIRProxy.postprocessors.DateSortPostProcessor;' : ''
var participantFilterString  = (enableParticipantFilter) ? 'FHIRProxy.postprocessors.ParticipantFilterPostProcess;' : ''
var fhirCdsSyncAgentString = (enableFhirCdsSyncAgent) ? 'FHIRProxy.postprocessors.FHIRCDSSyncAgentPostProcess2;' : ''
var publishFhirEventString = (enablePublishFhirEvent) ? 'FHIRProxy.postprocessors.PublishFHIREventPostProcess;' : ''


var proxyPostProcessSettings = '${consentOptOutString}${dateSortString}${participantFilterString}${fhirCdsSyncAgentString}${publishFhirEventString}' 
var fhirProxyPostProcess  = take(proxyPostProcessSettings, length(proxyPostProcessSettings)-1)

var roleAdmin = 'Administrator'
var roleReader = 'Reader'
var roleWriter = 'Writer'
var rolePatient = 'Patient'
var roleParticipant = 'Practitioner,RelatedPerson'
var roleGlobal = 'DataScientist'

resource fhirProxyAppSettings 'Microsoft.Web/sites/config@2021-02-01' = {
  name: 'appsettings'
  parent: fhirProxyFunctionApp
  properties: {
    'FUNCTIONS_EXTENSION_VERSION': '~3'
    'FUNCTIONS_WORKER_RUNTIME': 'dotnet'
    'APPINSIGHTS_INSTRUMENTATIONKEY':proxyAppInsights.properties.InstrumentationKey
    'AzureWebJobsStorage': 'DefaultEndpointsProtocol=https;AccountName=${functionsStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(functionsStorageAccount.id, functionsStorageAccount.apiVersion).keys[0].value}'
    'FP-ADMIN-ROLE': roleAdmin
    'FP-READER-ROLE': roleReader
    'FP-WRITER-ROLE': roleWriter
    'FP-GLOBAL-ACCESS-ROLES': roleGlobal
    'FP-PATIENT-ACCESS-ROLES': rolePatient
    'FP-PARTICIPANT-ACCESS-ROLES': roleParticipant
    'FP-HOST': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/FP-HOST/)'
    'FP-MOD-CONSENT-OPTOUT-CATEGORY' : (enableConsentOptOut) ? 'http://loinc.org|59284-0' : ''
    'FP-PRE-PROCESSOR-TYPES': empty(fhirProxyPreProcess) ? 'FHIRProxy.preprocessors.TransformBundlePreProcess' : fhirProxyPreProcess
    'FP-POST-PROCESSOR-TYPES': empty(fhirProxyPostProcess) ? '' : fhirProxyPostProcess
    'FP-RBAC-NAME':'@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/FP-RBAC-NAME/)'
    'FP-RBAC-TENANT-NAME':'@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/FP-RBAC-TENANT-NAME/)'
    'FP-RBAC-CLIENT-ID':'@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/FP-RBAC-CLIENT-ID/)'
    'FP-RBAC-CLIENT-SECRET':'@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/FP-RBAC-CLIENT-SECRET/)'
    'FS-CLIENT-ID': ''
    'FS-SECRET': ''
    
    // revised setting to Key Vault secret mapping
    'FS-URL': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/fhirServiceUrl/)'
    'FS-RESOURCE': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/fhirServiceUrl/)'
    'FP-STORAGEACCT': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/functionsStorageAccountConnectionString/)'
    'FP-REDISCONNECTION': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/proxyRedisConnectionString/)'
    'FS-TENANT-NAME': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/fhirServiceTenantName/)'
  }
}

// export storage account connection string should be written to Key Vault (convert to MSI/Azure RBAC in the future)
// for now just dump the connection string into the App Settings
// use MSI
resource fhirLoaderAppSettings 'Microsoft.Web/sites/config@2021-02-01' = {
  name: 'appsettings'
  parent: fhirLoaderFunctionApp
  properties: {
    'FUNCTIONS_EXTENSION_VERSION': '~3'
    'FUNCTIONS_WORKER_RUNTIME': 'dotnet'
    'APPINSIGHTS_INSTRUMENTATIONKEY': loaderAppInsights.properties.InstrumentationKey
    'AzureWebJobsStorage': 'DefaultEndpointsProtocol=https;AccountName=${functionsStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(functionsStorageAccount.id, functionsStorageAccount.apiVersion).keys[0].value}'
   
    'AzureWebJobs.ImportBundleBlobTrigger.Disabled': '1'

    'FS-URL': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/fhirServiceUrl/)'
    'FS-TENANT-NAME': ''
    'FP-HOST': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/proxyServiceUrl/)'
    'FS-CLIENT-ID': ''
    'FS-SECRET': ''
    'FS-RESOURCE': '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/fhirServiceUrl/)'

    'FBI-TRANSFORMBUNDLES' : 'true'
    'FBI-POOLEDCON-MAXCONNECTIONS': '20'
    'FBI-STORAGEACCT': 'DefaultEndpointsProtocol=https;AccountName=${exportStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(exportStorageAccount.id, exportStorageAccount.apiVersion).keys[0].value}'
  }
}

//deploy fhir loader code
resource deployLoaderUsingCD 'Microsoft.Web/sites/sourcecontrols@2020-12-01' = {
  dependsOn: [
    fhirLoaderAppSettings
  ]
  name:'web'
  parent: fhirLoaderFunctionApp
  properties: {
    repoUrl: fhirLoaderRepoUrl
    branch: fhirLoaderRepoBranch
    isManualIntegration: true
  }
}
// deploy fhir proxy code
resource deployProxyUsingCD 'Microsoft.Web/sites/sourcecontrols@2020-12-01' = {
  dependsOn: [
    fhirProxyAppSettings
  ]
  name:'web'
  parent: fhirProxyFunctionApp
  properties: {
    repoUrl: fhirProxyRepoUrl
    branch: fhirProxyRepoBranch
    isManualIntegration: true
  }
}

// Event Grid configuration
resource loaderEventGridSystemTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: loaderEventGridTopicName
  location: resourceLocation
  tags: resourceTags
  properties: {
    source: exportStorageAccount.id
    topicType: 'microsoft.storage.storageaccounts'
  }
}
resource loaderEventGridSubscription 'Microsoft.EventGrid/eventSubscriptions@2021-06-01-preview' = {
  name: 'bundlecreated'
  scope: exportStorageAccount
  dependsOn: [
    deployLoaderUsingCD
  ]
  properties:{
    eventDeliverySchema: 'EventGridSchema'
    destination: {
      endpointType: 'AzureFunction'
      properties:{
        resourceId: '${fhirLoaderFunctionApp.id}/functions/ImportBundleEventGrid'
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
    }
    filter: {
      subjectEndsWith: '.json'
      includedEventTypes: [ 
        'Microsoft.Storage.BlobCreated'
				'Microsoft.Storage.BlobDeleted'
      ]
      advancedFilters: [
        {
          operatorType: 'StringIn'
          values: [
            'CopyBlob'
            'PutBlob'
            'PutBlockList'
            'FlushWithClose'
          ]
          key: 'data.api'
        }
      ]
    }
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}
resource loaderEventGridSubscriptionND 'Microsoft.EventGrid/eventSubscriptions@2021-06-01-preview' = {
  name: 'ndjsoncreated'
  scope: exportStorageAccount
  dependsOn: [
    deployLoaderUsingCD
  ]
  properties:{
    eventDeliverySchema: 'EventGridSchema'
    destination: {
      endpointType: 'AzureFunction'
      properties:{
        resourceId: '${fhirLoaderFunctionApp.id}/functions/ImportNDJSON'
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
    }
    filter: {
      subjectEndsWith: '.ndjson'
      includedEventTypes: [ 
        'Microsoft.Storage.BlobCreated'
				'Microsoft.Storage.BlobDeleted'
      ]
      advancedFilters: [
        {
          operatorType: 'StringIn'
          values: [
            'CopyBlob'
            'PutBlob'
            'PutBlockList'
            'FlushWithClose'
          ]
          key: 'data.api'
        }
      ]
    }
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}
resource loaderEventGridSystemTopicDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: loaderEventGridSystemTopic
  name: 'defaultSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy:{
          enabled: true
          days: 7
        }
      }
    ]
  }
}

//Key Vault Permissions
resource functionAppKeyVaultPermissions 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        objectId: fhirProxyFunctionApp.identity.principalId
        permissions: {
          certificates: [ 
            'get'
           ]
          keys: [ 
            'get' 
          ]
          secrets: [ 
            'get' 
          ]
        }
        tenantId: tenantId
      }
      {
        objectId: fhirLoaderFunctionApp.identity.principalId
        permissions: {
          certificates: [ 
            'get'
           ]
          keys: [ 
            'get' 
          ]
          secrets: [ 
            'get' 
          ]
        }
        tenantId: tenantId
      }
    ]
  }
}

// fhir proxy auth settings
/*
resource fhirProxyAuthenticationSettings 'Microsoft.Web/sites/config@2021-02-01' = {
  name: 'authsettingsV2'
  kind: 'string'
  parent: fhirProxyFunctionApp
  properties: {
    globalValidation: {
      requireAuthentication: false
      unauthenticatedClientAction: 'AllowAnonymous'
    }
    httpSettings: {
      requireHttps: true
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        isAutoProvisioned: bool
        login: {
          disableWWWAuthenticate: bool
          loginParameters: [ 
            'string' 
          ]
        }
        registration: {
          clientId: 'string'
          clientSecretCertificateIssuer: 'string'
          clientSecretCertificateSubjectAlternativeName: 'string'
          clientSecretCertificateThumbprint: 'string'
          clientSecretSettingName: 'string'
          openIdIssuer: 'string'
        }
        validation: {
          allowedAudiences: [ 
            'string' 
          ]
          defaultAuthorizationPolicy: {
            allowedApplications: [ 
              'string' 
            ]
            allowedPrincipals: {
              groups: [ 
                'string' 
              ]
              identities: [ 
                'string' 
              ]
            }
          }
          jwtClaimChecks: {
            allowedClientApplications: [ 
              'string' 
            ]
            allowedGroups: [ 
              'string' 
            ]
          }
        }
      }
      azureStaticWebApps: {
        enabled: bool
        registration: {
          clientId: 'string'
        }
      }
      customOpenIdConnectProviders: {}
      legacyMicrosoftAccount: {
        enabled: bool
        login: {
          scopes: [ 
            'string' 
          ]
        }
        registration: {
          clientId: 'string'
          clientSecretSettingName: 'string'
        }
        validation: {
          allowedAudiences: [ 
            'string' 
          ]
        }
      }
    }
    login: {
      allowedExternalRedirectUrls: [ 
        'string' 
      ]
      cookieExpiration: {
        convention: 'string'
        timeToExpiration: 'string'
      }
      nonce: {
        nonceExpirationInterval: 'string'
        validateNonce: bool
      }
      preserveUrlFragmentsForLogins: bool
      routes: {
        logoutEndpoint: 'string'
      }
      tokenStore: {
        azureBlobStorage: {
          sasUrlSettingName: 'string'
        }
        enabled: true
        tokenRefreshExtensionHours: int
      }
    }
    platform: {
      configFilePath: 'string'
      enabled: bool
      runtimeVersion: 'string'
    }
  }
}
*/


output deploymentUniqueId string = uniqueId
output keyVaultName string = keyVault.name
output fhirServiceUrl string = apiForFhir.properties.authenticationConfiguration.audience
output fhirServiceAuthority string = apiForFhir.properties.authenticationConfiguration.authority
output fhirServiceExportStorageAccountName string = apiForFhir.properties.exportConfiguration.storageAccountName
output fhirServiceRegistryList array = apiForFhir.properties.acrConfiguration.loginServers
output fhirServiceManagedIdentity string = apiForFhir.identity.principalId
output fhirLoaderManagedIdentity string = fhirLoaderFunctionApp.identity.principalId
output fhirProxyManagedIdentity string = fhirProxyFunctionApp.identity.principalId
