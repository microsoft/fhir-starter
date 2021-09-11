# Instructions 

## Download the Postman files 
Instructions for downloading the Postman files can found [here](https://docs.microsoft.com/en-us/azure/cloud-shell/using-the-shell-window#upload-and-download-files)

__Note__ Each file must be downloaded individually (you can not use a wild card character for downloading from the Cloud shell)

An alternative to downloading each file individually is to compress the files into a single .zip file, downloading and then un-compressing them.  

File Names to download are:
 - /home/$username/fhir-starter/scripts/FHIR-CALLS-Sample-postman-collection.json
 - /home/$username/fhir-starter/scripts/$fhirServiceName.postman_environment.json 



## Using Postman to Connect to FHIR Server

1. [Download and Install Postman API App](https://www.postman.com/downloads/)

2. Select an existing or Create a New Postman Workspace

3. Select the import button next to your workspace name ![Import Postman](./images/postman1.png)

4. Import the ```servername.postman_environment.json``` file (see Download the Postman files above):
    + Upload the file using the upload file button or
    + Paste in the contents of the file useing the Raw Text tab
    ![Import Postman](./images/postman2.png)

5. Import the ```FHIR-CALLS-Sample-postman-collection.json``` file (see Download the Postman files above):
    + Upload the file using the upload file button or
    + Paste in the contents of the file useing the Raw Text tab

6. Select the ```servername``` postman environment in the workspace. (For Example my workspance name is stocore)
   ![Import Postman](./images/postman3.png)

7. Select the ```AuthorizationGetToken``` call from the ```FHIR Calls-Sample``` collection
   ![Import Postman](./images/postman4.png)

8. Press __send__ you should receive a valid token it will be automatically set in the bearerToken variable for the environment
   ![Import Postman](./images/postman5.png)

9. Select the ```List Patients``` call from the ```FHIR Calls-Samples``` collection
   ![Import Postman](./images/postman6.png)

__NOTE__  For your convenience a Sample Patient file is included in the ```Save Patients``` call.  Simply obtain a Token (see 7 above), and Press send to create a patient. 

10. Press send you should receive and empty bundle of patients from the FHIR Server (unless you created a Patient in Step 9)
   ![Import Postman](./images/postman7.png)

11. You may now use the token received for the other sample calls or your own calls.  Note: After token expiry (60 min), use the ```AuthorizationGetToken``` call to get another token

