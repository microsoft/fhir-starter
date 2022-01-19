# Postman Instructions 

## Download the Postman files 
You will use the ```Download``` feature in Azure Cloud Shell to download* the two **Postman** configuration files needed to get started. These files will download to your local desktop environment.

\*Detailed instructions for using the ```Upload/Download``` feature in Azure Cloud Shell can found [here](https://docs.microsoft.com/en-us/azure/cloud-shell/using-the-shell-window#upload-and-download-files).


__Note:__ Each file must be downloaded individually. 

Files to download to your desktop from Azure Cloud Shell:
 - ```/home/$username/fhir-starter/scripts/FHIR-CALLS-Sample-postman-collection.json```
 - ```/home/$username/fhir-starter/scripts/$fhirServiceName.postman_environment.json``` 

(```$fhirServiceName``` is a placeholder for the name given to your Azure API for FHIR deployment)



## Using Postman to connect to Azure API for FHIR

1. [Download and install the Postman app](https://www.postman.com/downloads/) (if you haven't already).

2. Create a new Postman Workspace (or select an existing one if already created).

3. Click the ```Import``` button next to your workspace name. ![Import Postman](./images/postman1.png)

4. Import the ```$fhirServiceName.postman_environment.json``` file that you downloaded to your desktop environment (see top):
    + Add the file to Postman using the ```Upload Files``` button or paste in the contents of the file using the ```Raw text``` tab.
    ![Import Postman](./images/postman2.png)

5. Import the ```FHIR-CALLS-Sample-postman-collection.json``` file that you downloaded to your desktop environment (see top):
    + Add the file to Postman using the ```Upload Files``` button or paste in the contents of the file using the ```Raw text``` tab.

6. Select the ```$fhirServiceName``` Postman environment in the workspace. (e.g. ```stocore``` as seen below is a Postman environment name).
   ![Import Postman](./images/postman3.png)

7. Select the ```POST AuthorizeGetToken``` call from the ```FHIR CALLS-Sample``` collection.
   ![Import Postman](./images/postman4.png)

8. Press ```Send```. You should receive a valid token automatically set in the bearerToken variable for the Postman environment.
   ![Import Postman](./images/postman5.png)

9. Select the ```GET List Patients``` call from the ```FHIR CALLS-Sample``` collection.
   ![Import Postman](./images/postman6.png)

10. Press ```Send```. You should receive an empty bundle of patients from Azure API for FHIR.
   ![Import Postman](./images/postman7.png)
   
11. For your convenience, a sample Patient record is included in the ```POST Save Patient``` call. Select ```POST Save Patient``` and press ```Send``` to create a Patient Resource in Azure API for FHIR.  

12. You may now experiment with other sample calls or your own calls.  

__Note:__ After token expiry (60 min), use the ```POST AuthorizeGetToken``` call again to obtain another token.

