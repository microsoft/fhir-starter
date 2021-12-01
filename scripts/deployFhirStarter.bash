#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)
#
# FHIR API and keyVaultName setup --- Author Steve Ordahl Principal Architect Health Data Platform
#


#########################################
# HealthArchitecture Deployment Settings 
#########################################
declare TAG="HealthArchitectures: FHIRStarter"


#########################################
# FHIR Starter Default App Settings 
#########################################
declare suffix=$RANDOM
declare defresourceGroupLocation="eastus2"
declare defresourceGroupName="api-fhir-"$suffix
declare defFhirServiceName="fhir"$suffix
declare defkeyVaultName="kv-"$defFhirServiceName
declare genPostmanEnv="yes"




#########################################
# Common Variables
#########################################
declare script_dir="$( cd -P -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )"
declare defSubscriptionId=""
declare subscriptionId=""
declare resourceGroupName=""
declare resourceGroupExists=""
declare useExistingResourceGroup=""
declare createNewResourceGroup=""
declare resourceGroupLocation=""
declare storageAccountNameSuffix="store"
declare storageConnectionString=""
declare serviceplanSuffix="asp"
declare stepresult=""
declare distribution="distribution/publish.zip"
declare postmanTemplate="postmantemplate.json"

# FHIR
declare fhirServiceUrl=""
declare fhirServiceClientId=""
declare fhirServiceClientSecret=""
declare fhirServiceTenantId=""
declare fhirServiceAudience=""
declare fhirResourceId=""
declare fhirServiceName=""
declare fhirServiceExists=""
declare fhirServiceProperties=""
declare fhirServiceClientAppName=""
declare fhirServiceClientObjectId=""
declare fhirServiceClientRoleAssignment=""


# Keyvault
declare keyVaultNameAccountNameSuffix="kv"
declare keyVaultName=""
declare keyVaultExists=""
declare createNewKeyVault=""
declare useExistingKeyVault=""

# Postman 
declare genpostman=""
declare pmenv=""
declare pmuuid=""
declare pmfhirurl=""


declare fsresourceid=""
declare fhirServiceAudience=""

declare spname=""
declare repurls=""



#########################################
#  Script Functions 
#########################################

function intro {
	# Display the intro - give the user a chance to cancel 
	#
	echo " "
	echo "FHIR API Application deployment script... "
	echo " - Prerequisite:  Must have rights to provision Resources within the Subscription (ie Contributor) "
    echo " - Prerequisite:  Azure CLI (bash) access from the Azure Portal"
	echo " "
	echo "The script gathers information then lets users choose to use a template or script deployment.  "
    echo "Users without CLI Access can use the template deployment from the templates directory in this repo."
	echo " "
	read -p 'Press Enter to continue, or Ctrl+C to exit'
}

function retry {
	# Retry logic  
    local n=1
    local max=5
    local delay=20
    while true; do
      "$@" && break || {
        if [[ $n -lt $max ]]; then
          ((n++))
          echo "Command failed. Retry Attempt $n/$max in $delay seconds:" >&2
          sleep $delay;
        else
          echo "The command has failed after $n attempts."
		  exit 1 ;
        fi
      }
    done
}

function keyVaultUri {
	echo "@Microsoft.keyVault(SecretUri=https://"$kvname".vault.azure.net/secrets/"$@"/)"
}

function result () {
    if [[ $1 = "ok" ]]; then
        echo -e ".....  [ \033[32m ok \033[37m ] \r" 
      else
        echo -e ".....  [ \033[31m failed \033[37m ] \r"
        exit 1
      fi
    echo -e "\033[37m \r"
    sleep 1
}

function appState () {
	az functionapp show --name $1 --resource-group $2 | grep state
	sleep 2
}


usage() { echo "Usage: $0  -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation> -k <keyVaultName> -n <fhirServiceName> -p <yes -or - no>" 1>&2; exit 1; }



#####################################################
#  Script Main Body (start script execution here)
#####################################################

# Initialize parameters specified from command line
#
while getopts ":i:g:l:k:n:p:" arg; do
	case "${arg}" in
		k)
			keyVaultName=${OPTARG}
			;;
		n)
			fhirServiceName=${OPTARG:0:14}
			fhirServiceName=${fhirServiceName,,}
			fhirServiceName=${fhirServiceName//[^[:alnum:]]/}
			;;
		p)
			genpostman=${OPTARG}
			;;
		i)
			subscriptionId=${OPTARG}
			;;
		g)
			resourceGroupName=${OPTARG}
			;;
		l)
			resourceGroupLocation=${OPTARG}
			;;
	esac
done
shift $((OPTIND-1))
echo "Executing "$0"..."
echo "Checking Azure Authentication..."

# login to azure using your credentials
az account show 1> /dev/null

if [ $? != 0 ];
then
	az login
fi

# set default subscription information
defSubscriptionId=$(az account show --query "id" --out json | sed 's/"//g') 

# Test for correct directory path / destination 
if [ -f "${script_dir}/$0" ] && [ -f "${script_dir}/postmantemplate.json" ] ; then
	echo "Checking Script execution directory..."
else
	echo "Please ensure you launch this script from within the ./scripts directory"
	usage ;
fi

# Call the Introduction function 
intro

# ---------------------------------------------------------------------
# Prompt for common parameters if some required parameters are missing
#
echo "--- "
echo "Collecting Azure Parameters (unless supplied on the command line) "

if [[ -z "$subscriptionId" ]]; then
	echo "Enter your subscription ID <press Enter to accept default> ["$defSubscriptionId"]: "
	read subscriptionId
	if [ -z "$subscriptionId" ] ; then
		subscriptionId=$defSubscriptionId
	fi
	[[ "${subscriptionId:?}" ]]
fi

if [[ -z "$resourceGroupName" ]]; then
	echo "This script will look for an existing resource group, otherwise a new one will be created "
	echo "You can create new resource groups with the CLI using: az group create "
	echo "Enter a resource group name <press Enter to accept default> ["$defresourceGroupName"]: "
	read resourceGroupName
	if [ -z "$resourceGroupName" ] ; then
		resourceGroupName=$defresourceGroupName
	fi
	[[ "${resourceGroupName:?}" ]]
fi

if [[ -z "$resourceGroupLocation" ]]; then
	echo "If creating a *new* resource group, you need to set a location "
	echo "You can lookup locations with the CLI using: az account list-locations "
    echo "Azure API is currently availalbe in: East US, East US 2, North Central US, South Central US, West US, West US 2 "
	echo "Enter resource group location <press Enter to accept default> ["$defresourceGroupLocation"]: "
	read resourceGroupLocation
	if [ -z "$resourceGroupLocation" ] ; then
		resourceGroupLocation=$defresourceGroupLocation
	fi
	[[ "${resourceGroupLocation:?}" ]]
fi

# Ensure there are subscriptionId and resourcegroup names 
#
if [ -z "$subscriptionId" ] || [ -z "$resourceGroupName" ]; then
	echo "Either one of subscriptionId, resourceGroupName is empty, exiting..."
	usage
fi

# Check if the resource group exists
#
echo " "
echo "  Checking for existing Resource Group named ["$resourceGroupName"]... "
resourceGroupExists=$(az group exists --name $resourceGroupName)
if [[ "$resourceGroupExists" == "true" ]]; then
    echo "  Resource Group ["$resourceGroupName"] found"
    useExistingResourceGroup="yes" 
    createNewResourceGroup="no" ;
else
    echo "  Resource Group ["$resourceGroupName"] not found a new Resource group will be created"
    useExistingResourceGroup="no" 
    createNewResourceGroup="yes"
fi

# ---------------------------------------------------------------------
# Prompt for script parameters if some required parameters are missing
#
echo "--- "
echo "Collecting Script Parameters (unless supplied on the command line).."

# Set a Default values for App Name and Keyvault
#
defFhirServiceName=${defFhirServiceName:0:14}
defFhirServiceName=${defFhirServiceName//[^[:alnum:]]/}
defFhirServiceName=${defFhirServiceName,,}

# Prompt for deployment prefix, otherwise use the defaulf 
#
if [[ -z "$fhirServiceName" ]]; then
	echo "Enter your FHIR Service name <press Enter to accept default> ["$defFhirServiceName"]:"
	read fhirServiceName
	if [ -z "$fhirServiceName" ] ; then
		fhirServiceName=$defFhirServiceName
	fi
	fhirServiceName=${fhirServiceName:0:14}
	fhirServiceName=${fhirServiceName//[^[:alnum:]]/}
    fhirServiceName=${fhirServiceName,,}
	[[ "${fhirServiceName:?}" ]]
fi

# Check FHIR Service exists
#
declare answer=""
echo "  Checking for exiting FHIR Service named ["$fhirServiceName"] ...Warnings can be safely ignored... "
stepresult=$(az config set extension.use_dynamic_install=yes_without_prompt)
fhirServiceExists=$(az healthcareapis service list --query "[?name == '$fhirServiceName'].name" --out tsv)
if [[ -n "$fhirServiceExists" ]]; then
	echo "  An API for FHIR Service Named "$fhirServiceName" already exists in this subscription, would you like to try ["$defFhirServiceName"] instead? [y/n]: "
    read answer
    if [[ "$answer" == "y" ]]; then
        fhirServiceName=$defFhirServiceName 
        stepresult=$(az config set extension.use_dynamic_install=yes_without_prompt)
        fhirServiceExists=$(az healthcareapis service list --query "[?name == '$fhirServiceName'].name" --out tsv)
        if [[ -n "$fhirServiceExists" ]]; then
            echo "  An API for FHIR Service Named "$fhirServiceName" already exists in this subscription, exiting..."
            exit 1
        fi ;
    else 
        echo "Please select another name and try again"
        exit 1
    fi 
else 
    echo "  FHIR Service ["$fhirServiceName"] not found, a new FHIR Service will be created"
fi

# If we have a valid FHIR Service Name, then create the FHIR Service Client name variable from it
#
fhirServiceClientAppName=$fhirServiceName"-svc-client"

# Set a Default KeyVault Name 
#
defkeyVaultName=${defkeyVaultName:0:14}
defkeyVaultName=${defkeyVaultName//[^[:alnum:]]/}
defkeyVaultName=${defkeyVaultName,,}

# Prompt for remaining details 
#
echo " "
if [[ -z "$keyVaultName" ]]; then
	echo "Enter a Key Vault name <press Enter to accept default> ["$defkeyVaultName"]:"
	read keyVaultName
	if [ -z "$keyVaultName" ] ; then
		keyVaultName=$defkeyVaultName
	fi
	keyVaultName=${keyVaultName:0:14}
	keyVaultName=${keyVaultName//[^[:alnum:]]/}
    keyVaultName=${keyVaultName,,}
	[[ "${keyVaultName:?}" ]]
fi


# Check KV exists and load information 
#
echo "  Checking for existing Key Vault named ["$keyVaultName"]..."
keyVaultExists=$(az keyvault list --query "[?name == '$keyVaultName'].name" --out tsv)
if [[ -n "$keyVaultExists" ]]; then
	set +e
	echo "  "$keyVaultName "found"
	echo "  Checking ["$keyVaultName"] for FHIR Service configuration..."
	fhirServiceUrl=$(az keyvault secret show --vault-name $keyVaultName --name FS-URL --query "value" --out tsv)
	if [ -n "$fhirServiceUrl" ]; then
		echo "  found FHIR Service ["$fhirServiceUrl"]"
        fhirResourceId=$(az keyvault secret show --vault-name $keyVaultName --name FS-URL --query "value" --out tsv | awk -F. '{print $1}' | sed -e 's/https\:\/\///g') 
		echo "  FHIR Resource ID set to: ["$fhirResourceId"]" ;
	else	
		echo "  unable to read FS-URL from ["$keyVaultName"]" 
        echo "  setting script to create new FS-URL Entry in existing Key Vault ["$keyVaultName"]"
        useExistingKeyVault="yes"
        createNewKeyVault="no"
	fi 
else
	echo "  Script will deploy new Key Vault ["$keyVaultName"] for FHIR Service ["$fhirServiceName"]" 
    useExistingKeyVault="no"
    createNewKeyVault="yes"
fi


# Check for Postman Environment Variable 
#
echo " "
if [[ -z "$genpostman" ]]; then
	echo "Do you want to generate a Postman Environment for FHIR Service access? [y/n]:"
	read genpostman
	if [[ "$genpostman" == "y" ]]; then
        genpostman="yes" ;
    else
        genpostman="no"
    fi
fi


# Prompt for final confirmation
#
echo "--- "
echo "Ready to start deployment of new FHIR Service: ["$fhirServiceName"] with the following values:"
echo "Subscription ID:....................... "$subscriptionId
echo "Resource Group Name:................... "$resourceGroupName 
echo " Use Existing Resource Group:.......... "$useExistingResourceGroup
echo " Create New Resource Group:............ "$createNewResourceGroup
echo "Resource Group Location:............... "$resourceGroupLocation 
echo "KeyVault Name:......................... "$keyVaultName
echo " Use Existing Key Vault:............... "$useExistingKeyVault
echo " Create New Key Vault:................. "$createNewKeyVault
echo "FHIR Service Client Application Name:.. "$fhirServiceClientAppName
echo "Generate Postman Environment:.......... "$genpostman  
echo " "
echo "Please validate the settings above before continuing"
read -p 'Press Enter to continue, or Ctrl+C to exit'



#############################################################
#  Start Azure Setup  
#############################################################
#
echo "--- "
echo "Starting Deployments "
(
    if [[ "$useExistingResourceGroup" == "no" ]]; then
        echo " "
        echo "Creating Resource Group ["$resourceGroupName"] in location ["$resourceGroupLocation"]"
        set -x
        az group create --name $resourceGroupName --location $resourceGroupLocation --output none --tags $TAG ;
    else
        echo "Using Existing Resource Group ["$resourceGroupName"]"
    fi
)
	
if [ $?  != 0 ];
 then
	echo "Resource Group create failed.  Please check your permissions in this Subscription and try again"
    result "fail" 
fi

sleep 3

#############################################################
#  Deploy Key Vault 
#############################################################
#
echo "--- "
(
    if [[ "$useExistingKeyVault" == "no" ]]; then
        echo " "
        echo "Creating Key Vault ["$keyVaultName"] in location ["$resourceGroupName"]"
        set -x
        stepresult=$(az keyvault create --name $keyVaultName --resource-group $resourceGroupName --location  $resourceGroupLocation --tags $TAG --output none) ;
    else
        echo "Using Existing Key Vault ["$keyVaultName"]"
    fi
)

	
if [ $?  != 0 ];
 then
	echo "Key Vault create failed.  Please check your permissions in this Subscription and try again"
    result "fail" 
fi

sleep 5

#############################################################
#  Deploy FHIR Service
#############################################################
#
echo "--- "
echo "Deploying FHIR Service ["$fhirServiceName"]"
echo "... note that warnings here are expected and can be safely ignored ..."
(
    # Deploy API
    #
    echo " "
    echo "Creating FHIR Service ["$fhirServiceName"] in location ["$resourceGroupName"]"
    stepresult=$(az healthcareapis service create --resource-name $fhirServiceName --resource-group $resourceGroupName --location $resourceGroupLocation --subscription $subscriptionId --kind "fhir-R4" --cosmos-db-configuration offer-throughput=1000 --identity-type "none" --tags $TAG)
    
    sleep 5

    # Set FHIR Service Audience
    #
    fhirServiceAudience=$(az healthcareapis service show --resource-name "$fhirServiceName" --resource-group "$resourceGroupName" --query "properties.authenticationConfiguration.audience" --out tsv)

    echo " "
    echo "FHIR Service Audience set to ["$fhirServiceAudience"]"
    
    echo " "
    sleep 5

    # Set FHIR Service Resource ID 
    #
    fhirResourceId=$(az healthcareapis service show --resource-name "$fhirServiceName" --resource-group "$resourceGroupName" --query "id" --out tsv)

    echo " "
    echo "FHIR Service Resource ID set to ["$fhirResourceId"]" 

    sleep 5

    # Setup the FHIR Service Client Application 
    #
    echo " "
    echo "Creating FHIR Service Client Application ["$fhirServiceClientAppName"]"
    stepresult=$(az ad sp create-for-rbac --name $fhirServiceClientAppName --skip-assignment --only-show-errors)

    # Seriously hate doing this, but Azure doesn't have a way to get the client ID out of the response 
    # a better way is to us az ad sp show with the app ID... will solve next iteration 
    fhirServiceClientId=$(echo $stepresult | jq -r '.appId')
    fhirServiceClientSecret=$(echo $stepresult | jq -r '.password')
    fhirServiceTenantId=$(echo $stepresult | jq -r '.tenant')

    echo "FHIR Service Client Application ID is ["$fhirServiceClientId"]"
    
    # Set the FHIR Service Client Object ID for role assignment 
    #
    echo "--- "
    echo "Setting FHIR Service Client Object ID"
    fhirServiceClientObjectId=$(az ad sp show --id $fhirServiceClientId --query "objectId" --out tsv)

     # Save the FHIR Service Client Application information to the Key Vault 
    # 
    echo "--- "
    echo "Saving FHIR Service Client Information (FS-name) to Key Vault ["$keyVaultName"]"
    stepresult=$(az keyvault secret set --vault-name $keyVaultName --name "FS-TENANT-NAME" --value $fhirServiceTenantId)
    stepresult=$(az keyvault secret set --vault-name $keyVaultName --name "FS-CLIENT-ID" --value $fhirServiceClientId)
    stepresult=$(az keyvault secret set --vault-name $keyVaultName --name "FS-CLIENT-SECRET" --value $fhirServiceClientSecret)
    stepresult=$(az keyvault secret set --vault-name $keyVaultName --name "FS-SECRET" --value $fhirServiceClientSecret)
    stepresult=$(az keyvault secret set --vault-name $keyVaultName --name "FS-RESOURCE" --value $fhirServiceAudience)
    stepresult=$(az keyvault secret set --vault-name $keyVaultName --name "FS-URL" --value $fhirServiceAudience)

    # Granting FHIR Service Client Application FHIR Data Contributor Role
    # 
    echo "--- "
    echo "Granting FHIR Service Client Application FHIR Data Contributor Role"
    stepresult=$(az role assignment create --assignee-object-id $fhirServiceClientObjectId --assignee-principal-type ServicePrincipal --role "FHIR Data Contributor" --scope $fhirResourceId)

    # Generate Postman Environment File if requested
    # 
    if [[ "$genpostman" == "yes" ]]; then
        echo "--- "
        echo "Generating Postman Environment File"
            pmuuid=$(cat /proc/sys/kernel/random/uuid)
		    pmenv=$(<postmantemplate.json)
			pmfhirurl=$fhirServiceAudience
			pmenv=${pmenv/~guid~/$pmuuid}
			pmenv=${pmenv/~envname~/$fhirServiceName}
			pmenv=${pmenv/~tenentid~/$fhirServiceTenantId}
			pmenv=${pmenv/~clientid~/$fhirServiceClientId}
			pmenv=${pmenv/~clientsecret~/$fhirServiceClientSecret}
			pmenv=${pmenv/~fhirurl~/$pmfhirurl}
			pmenv=${pmenv/~resource~/$fhirServiceAudience}
			echo $pmenv >> $fhirServiceName".postman_environment.json"
        
            echo " "
        	echo "The Postman environment ["$fhirServiceName".postman_environment.json] has been generated"
			echo "The environment file along with the FHIR-CALLS-Sample-postman-collection.json can be used to access ["$fhirServiceName"]"
            echo " "
            echo "Download Files from Cloud Shell"
            echo "https://docs.microsoft.com/en-us/azure/cloud-shell/using-the-shell-window#upload-and-download-files"
            echo " "
            echo "Importing Postman files"
			echo "https://learning.postman.com/docs/getting-started/importing-and-exporting-data/#importing-postman-data"
    fi   
)

	
if [ $?  != 0 ];
 then
	echo "Deployment of FHIR Service failed.  Please check your permissions in this Subscription and try again"
    result "fail" ;
else 
    echo "************************************************************************************************************"
    echo "Deployment of FHIR Service ["$fhirServiceName"] and ["$fhirServiceClientAppName"] completed successfully"
    echo "The FHIR Service Client Application can be used for OAuth2 client_credentials flow authentication to the FHIR Server"
    echo "Client Credentials have been securely stored as Secrets in the Key Vault ["$keyVaultName"]"
    echo "The secret prefix is FS (for FHIR Service)"
    echo "************************************************************************************************************"
fi

   
