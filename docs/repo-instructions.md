# Instructions 

1. [Open Azure Cloud Shell](https://shell.azure.com) you can also access this from [Azure Portal](https://portal.azure.com)

2. Select Bash Shell for the environment 

3. Clone this repo
```azurecli
git clone https://github.com/microsoft/fhir-starter
```
4. Change Directory to the scripts working directory 
```azurecli
cd ./fhir-starter/scripts 
```
5. Make the bash script executable
```azurecli
chmod +x *.bash
```
6. Execute the script with (or without) command line parameters)

Without Command line parameters will prompt the user for necessary information 
```azurecli
./deployFhirStarter.bash
```

With Command line parameters will not prompt the user for necessary information (unless there is an issue)
```azurecli
./deployFhirStarter.bash  -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation> -k <keyVaultName> -n <fhirServiceName> -p
```
__Note__ -p will create a Postman Environment file for access from Postman


