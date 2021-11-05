# FHIR-Starter

## Introduction 

The goal of the **FHIR-Starter** is to ease the deployment of an Azure Healthcare API FHIR Service along with a Service Client to get users up and running with FHIR in minutes rather than days.  

Azure API for FHIr is generally availability for both public and government in multiple [geo-regions](https://azure.microsoft.com/en-us/global-infrastructure/services/?products=azure-api-for-fhir&regions=non-regional%2Cus-east%2Cus-east-2%2Cus-central%2Cus-north-central%2Cus-south-central%2Cus-west-central%2Cus-west%2Cus-west-2%2Ccanada-east%2Ccanada-central%2Cusgov-non-regional%2Cus-dod-central%2Cus-dod-east%2Cusgov-arizona%2Cusgov-texas%2Cusgov-virginia). For information about government cloud services at Microsoft, check out Azure services by [FedRAMP](https://docs.microsoft.com/en-us/azure/azure-government/compliance/azure-services-in-fedramp-auditscope). 

## Components 
![deployment](./docs/images/architecture/deployment.png)


## Repository Contents 

The table below lists items contained within this repository 

Directory       | Contains                                                
----------------|--------------------------------------------------
main            | Readme, Security and compliance documents 
docs            | Getting started documents  
scripts         | Readme + Deployment, Setup and Control scripts  
templates       | ARM Templates for customers without Cloud Shell access (__in progress__)


## Deployment
The FHIR-Starter script is designed for and tested from the Azure Cloud Shell - Bash Shell environment.  The following services are required as part of **FHIR-Starter** --  Detailed deployment instuctions are located in the [Readme.md](./scripts/Readme.md) within the scripts directory.

1) Azure Active Directory
2) Azure Healthcare API's for FHIR
3) Azure Key Vault

If you are ready to continue, you can find the deployment documentation [here](./scripts/Readme.md)


## Tracking Changes & Updates
We continue to monitor questions, feature requests and of course, bugs/issues.   You can review the issues list [here](https://github.com/microsoft/fhir-starter/issues)

If you are interested in receiving notifications when we publish updates then please follow this repo. 

## Resources
The following is a list of references that might be useful to the reader

* [Azure for the healthcare industry](https://azure.microsoft.com/en-us/industries/healthcare/)
* [Azure Healthcare APIs for FHIR](https://azure.microsoft.com/en-us/services/azure-api-for-fhir/)
* [Microsoft Cloud for Healthcare](https://www.microsoft.com/en-us/industry/health/microsoft-cloud-for-healthcare)


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
