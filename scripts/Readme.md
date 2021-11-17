# FHIR-Starter Getting started scripts Readme
Script purpose, order of execution and other steps necessary to get up and running with FHIR-SyncAgent

## Errata 
There are no open issues at this time. 

## Prerequisites 

These scripts will gather (and export) information necessary to the proper deployment and configuration of Azure Healthcare API for FHIR, an Application Service Client, Key Vault and Resource Groups secure information will be stored in the Keyvault.  
 - Prerequisites:  User must have rights to deploy resources at the Subscription scope 

__Note__
A Keyvault is necessary for securing Service Client Credentials used with the FHIR Service and FHIR-Proxy.  Only 1 Keyvault should be used as this script scans the keyvault for FHIR Service and FHIR-Proxy values. If multiple Keyvaults have been used, please use the [backup and restore](https://docs.microsoft.com/en-us/azure/key-vault/general/backup?tabs=azure-cli) option to copy values to 1 keyvault.

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
 - Azure AD Application Service Client 

Information needed by this script 
 - FHIR Service Name
 - KeyVault Name 
 - Resource Group Location 
 - Resource Group Name 

__FHIR-Starter__ Key Vault values saved by this script 

Name              | Value                                | Use             
------------------|--------------------------------------|---------------------------------
FS-TENANT-NAME    | Azure AD Tenant GUID                 | Tenant where Client applications can obtain a Token 
FS-CLIENT-ID      | Service Client Application ID        | Client Application ID used for Token Access  
FS-CLIENT-SECRET  | Service Client Application Secret    | Client Application Secret used for Token Access                    
FS-SECRET         | Service Client Application Secret    | Saved for backwards compatibility  
FS-RESOURCE       | Application Endpoint for Auth Access | Endpoint for Authority (AD) Token grant  
FS-URL            | Application Endpoint for Clients     | Endpoint for FHIR Service interaction 



## Step 3.  Setup Postman
Once the script finishes deployment, users can use Postman to test access to the new FHIR Service.  Instructions on setting up Postman can be found in the docs directory [here](../docs/postman.md).

### Auth Layout

![auth](../docs/images/architecture/starter_auth.png)
