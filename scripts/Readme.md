# FHIR-Starter Getting started scripts Readme
Script purpose, order of execution and other steps necessary to get up and running with FHIR-SyncAgent

## Errata 
There are no open issues at this time. 

## Prerequisites 
HealthArchitecture scripts will gather (and export) information necessary to the proper deployment and configuration of Azure API for FHIR and multiple other HealthArchitecture Open Source Software systems.  
+ Prerequisite:  User must have rights to deploy resources at the Subscription scope (ie Contributor)
+ Prerequisite:  User must have Application Administrator (built In RBAC role) rights for the Tenant they are deploying into

### Keyvaults 
+ A Keyvault is necessary for securing Service Client Credentials used with the FHIR Service and FHIR-Proxy.  Only 1 Keyvault can be used for HealthArchitecture applications as scripts scans the keyvault for FHIR Service and FHIR-Proxy values. If multiple Keyvaults have been used, please use the [backup and restore](https://docs.microsoft.com/en-us/azure/key-vault/general/backup?tabs=azure-cli) option to copy values to 1 keyvault.
+ Existing Keyvaults can be used however, the user running this script MUST be able to Read, List, Set and Purge Secrets.  If you are un-sure of your rights on the existing Keyvault, use this script to create a new one. 

### Naming
As with most Azure Services names must be unique across the namespace (ie azurehealthcareapis.com), therefore our scripts suggest default names that align with the Azure Naming rules (https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules) while still being readable.  Consider your companies local naming rules, but please understand that:  

- If a name is too long, it will be truncated
- If a name has an illegal character the default will be used
- If a name is invalid, the default will be used 

__Note__ 
Chaning variable names within Application Configurations will break code   

__Note__ 
The FHIR-Starter scripts are designed for and tested from the Azure Cloud Shell - Bash Shell environment.  

## Step 1. Setup 
Please note you should deploy these components into a tenant that you have appropriate permissions to create and manage Application Registrations, Enterprise Applications, Permissions and Role Definitions Assignments

1. [Get or Obtain a valid Azure Subscription](https://azure.microsoft.com/en-us/free/)

2. [Open Azure Cloud Shell](https://shell.azure.com) you can also access this from [azure portal](https://portal.azure.com)

3. Select Bash Shell 

4. Clone this repo 
```azurecli
git clone https://github.com/microsoft/fhir-starter
```

5. Change to the new directory to keep files organized within the fhir-starter directory
```azurecli
cd ./fhir-starter/scripts
```

6. Make the bash scripts executable
```azurecli
chmod +x *.bash
``` 

## Step 2.  deployFhirStarter.bash
This is the main component deployment script for the Azure Components.    

Run the deployment script and follow the prompts
```azurecli
./deployFhirStarter.bash 
```

Optionally the deployment script can be used with command line options 
```azurecli
./deployFhirStarter.bash -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation> -k <keyVaultName> -n <fhirServiceName> -p <yes -or - no>
```

Azure Components installed 
 - Resource Group (if needed)
 - Healthcare API for FHIR 
 - Key Vault 
 - Azure AD Application Service Principle  

Information needed by this script 
 - FHIR Service Name
 - KeyVault Name 
 - Resource Group Location 
 - Resource Group Name 

__FHIR-Starter__ Key Vault values saved by this script 

Name              | Value                                   | Use             
------------------|-----------------------------------------|---------------------------------
FS-TENANT-NAME    | Azure AD Tenant GUID                    | Tenant where Client applications can obtain a Token 
FS-CLIENT-ID      | Service Principle Application ID        | Client Application ID used for Token Access  
FS-CLIENT-SECRET  | Service Principle Application Secret    | Client Application Secret used for Token Access                    
FS-SECRET         | Service Principle Application Secret    | Saved for backwards compatibility  
FS-RESOURCE       | Application Endpoint for Auth Access    | Endpoint for Authority (AD) Token grant  
FS-URL            | Application Endpoint for Clients        | Endpoint for FHIR Service interaction 


## Auth Layout
Azure FHIR uses an Application Service principal for token access.  Token access is needed for Postman, and other 3rd party apps connecting to the FHIR Service.  A Service Principle can be considered an instance of an application, generally referencing an application object, which can be referenced by multiple service principals across directories.

Typical Postman Auth scenario / setup 
  
![auth](../docs/images/architecture/starter_auth.png)

  

## Step 3.  Setup Postman
Once the script finishes deployment, users can use Postman to test access to the new FHIR Service.  Instructions on setting up Postman can be found in the docs directory [here](../docs/postman.md).
  