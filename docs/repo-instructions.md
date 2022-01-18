# Instructions 

1. [Open Azure Cloud Shell](https://shell.azure.com) (you can also access the Azure Cloud Shell CLI directly from [Azure Portal](https://portal.azure.com))

2. Select Bash Shell for the environment 

3. Clone this repo
```azurecli
git clone https://github.com/microsoft/fhir-starter.git
```
4. Change the working directory to the ```./fhir-starter/scripts``` directory
```azurecli
cd $HOME/fhir-starter/scripts 
```
5. Make the Bash script executable
```azurecli
chmod +x *.bash
```
6. Execute the ```deployFhirStarter.bash``` script with or without command line parameters

If you call the script without entering the command line parameters, the script will prompt you for necessary information (```subscriptionId```, ```resourceGroupName```, ```resourceGroupLocation```, ```keyVaultName```, ```fhirServiceName```). 
```azurecli
./deployFhirStarter.bash
```

If you execute the script with command line parameters, the script will take the values you enter and use them to complete the deployment. 
```azurecli
./deployFhirStarter.bash  -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation> -k <keyVaultName> -n <fhirServiceName> -p
```
__Note__ -p will create a Postman Environment file for access from Postman


