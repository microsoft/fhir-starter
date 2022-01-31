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
+ Deployment Prefix (3-7 characters that will be used as a prefix to all created resources)


![Custom Deployment Page](./images/deploytrainenvportal.png)

Once the deployment has completed additional steps are necessary to complete the authentication configuration of the FHIR Proxy function app.
