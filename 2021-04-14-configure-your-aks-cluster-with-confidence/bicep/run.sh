export RG_NAME="webinar3"
export RG_LOCATION="eastus2"
export BICEP_FILE="000-main.bicep"
export WEBINAR_PARAMETERS="@parameters.json"
export SUFFIX=$(openssl rand -hex 2)

# Login to your Azure account
# az login

# Create the Resource Group to deploy the Webinar Environment
az group create --name $RG_NAME --location $RG_LOCATION

# Deploy
az deployment group create \
  --name webinarenvironment \
  --resource-group $RG_NAME \
  --template-file $BICEP_FILE \
  --parameters $WEBINAR_PARAMETERS \
  --parameters adminPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
  --mode Incremental