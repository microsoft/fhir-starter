# FHIR-Starter Quickstart   

## Introduction 

The quickstart Azure Resource Manager templates contained in this folder are intended to replicate, where possible, the fhir-starter bash scripts that are used and referenced by this repo.


## Deploy Training Environmment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FToddM2%2Ffhir-starter%2Fquickstarts%2Fquickstarts%2Fdeployfhirtrain.json)

The Azure Resource Manager / Bicep templates located in this folder will deploy the following services and solutions:
+ API for FHIR
+ FHIR Proxy
+ FHIR Loader

In an effort to simplify the deployment process Managed Service Identities are used wherevr possible. These templates currently link to a repo that contains modifications to ensure that MSI functions as expected. This repo is not in sync with the origin repos. The bicep code or corresponding ARM templates may be modified to update this reference.

There are only a few required parameters 
+ Subscription
+ Resource Group
+ Azure Region
Supported Regions:
    South Africa North,
    South East Asia,
    Australia East,
    Canada Central,
    North Europe,
    West Europe,
    Germany West Central,
    Japan East,
    Switzerland North,
    UK South,
    UK West,
    East US,
    East US 2,
    North Central US,
    South Central US,
    West Central US,
    West US 2
    
+ Deployment Prefix (3-7 characters that will be used as a prefix to all created resources)

In order to successfully deploy the template the user must have the Owner role for the resource group where the template is being deployed and have the ability to create application registrations in Azure Active Directory.


![Custom Deployment Page](./images/deploytrainenvportal.png)

Once the deployment has completed additional steps are necessary to complete the authentication configuration of the FHIR Proxy function app.
In the Azure Portal navigate to the function application that was deployed by the resource manager template
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH1.png)

Select the function app and select **Authentication**
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH2.png)

Select **Add Identity Provider**
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH3.png)

Select **Microsoft**
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH4.png)

Configure basic settings as follows:
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH5a.png)



Accept the default permissions
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH6.png)

At this point the application registration has been completed. Further configuration is required to define **App Roles and Permissions** click on the link next to the Microsoft identity provider, which will open the Azure AD blade.
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH7.png)

Select the **Manifest** option
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH8.png)

Update the **AppRoles** element using the data in the [app roles json](./fhirproxyroles.json) file
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH9.png)

The **AppRoles** element should look something like the following
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH10.png)

Select **API Permissions** and **Add a Permission**
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH11.png)

Select **APIs my organization uses**
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH12.png)

Filter the results to **Azure healthcare apis**
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH13.png)

Select **Azure healthcare APIs** user_impersonation permission
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH14.png)

Verify the **API Permissions**
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH15.png)

Review/verify that the the **App Roles** were created properly
![Enable Authentication Step 1](./images/FHIR-PROXY-AUTH16.png)