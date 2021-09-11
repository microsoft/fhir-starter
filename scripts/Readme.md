# FHIR-Starter Getting started scripts Readme
Script purpose, order of execution and other steps necessary to get up and running with FHIR-SyncAgent

## Errata 
There are no open issues at this time. 

## Prerequisites 

These scripts will gather (and export) information necessary to the proper deployment and configuration of Azure Healthcare API for FHIR, an Application Service Client, Key Vault and Resource Groups secure information will be stored in the Keyvault.  
 - Prerequisites:  User must have rights to deploy resoruces at the Subscription scope 

__Note__
A Keyvault is necessary for securing Service Client Credentials used with the FHIR Service and FHIR-Proxy.  Only 1 Keyvault should be used as this script scans the keyvault for FHIR Service and FHIR-Proxy values. If multiple Keyvaults have been used, please use the [backup and restore](https://docs.microsoft.com/en-us/azure/key-vault/general/backup?tabs=azure-cli) option to copy values to 1 keyvault.

__Note__ The FHIR-Starter scripts are designed for and tested from the Azure Cloud Shell - Bash Shell environment.


## Step 1.  deployFhirStarter.bash
This is the main component deployment script for the Azure Components.    

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



## Step 2.  Setup Postman
Once the script finishes deployment, users can use Postman to test access to the new FHIR Service.  Instructions on setting up Postman can be found in the docs directory [here](../docs/postman.md).

