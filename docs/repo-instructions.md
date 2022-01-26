# Deployment Instructions 

1. [Open Azure Cloud Shell](https://shell.azure.com) (you can also access the Azure Cloud Shell CLI directly from [Azure Portal](https://portal.azure.com))

2. Select Bash Shell for the environment 

3. In your Azure Cloud Shell environment, clone this repo
```azurecli
git clone https://github.com/microsoft/fhir-starter.git
```
4. Change the working directory in your Azure Cloud Shell environment to the ```./fhir-starter/scripts``` directory
```azurecli
cd $HOME/fhir-starter/scripts 
```
5. Make the Bash script in the directory executable
```azurecli
chmod +x *.bash
```
6. Execute the ```deployFhirStarter.bash``` script with or without command line option parameters:

      The script will prompt you to enter custom values for the following parameters if you decide not to accept the script's default generated values (```subscriptionId```,         ```resourceGroupName```, ```resourceGroupLocation```, ```keyVaultName```, ```fhirServiceName```). 
      ```azurecli
      ./deployFhirStarter.bash
      ```

      If you call the script and include command line option parameters, the script will take the values you enter and use them in the deployment. 
      ```azurecli
      ./deployFhirStarter.bash  -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation> -k <keyVaultName> -n <fhirServiceName> -p
      ```
      __Note:__ the ```-p``` option will create a Postman Environment file for access from Postman. See [here](https://github.com/microsoft/fhir-       starter/blob/main/docs/postman.md) for Postman setup instructions.


