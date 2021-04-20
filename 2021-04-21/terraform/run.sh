#! /bin/bash

export TF_VAR_prefix="webinar1tf"
export TF_VAR_suffix="randomsuffix"
export RG_LOCATION="eastus2"
export WEBINAR_PARAMETERS="terraform.tfvars"
export SSH_KEY="~/.ssh/id_rsa.pub"
export ACR_ROLE="AcrPull"

# Login to your Azure account
# az login

# Plan and deploy your Terraform template
#
# Terraform by default will read the current directory for Terraform (tf) files
# Initialize terraform - checks, downloads and installs required modules
terraform init

# Plans the deployment - what needs to be created/removed and plans out a provisioning plan based on resource dependencies 
#
# Note: Terraform is able to dynamically create Resource Groups within TF Templates.  You do not need to create RGs in advance
#
# Terraform automatically looks for a parameters file - terraform.tfvars.  You can specify anotehr file with the -var-file flag
# You may also pass in parameters/variables via shell export TF_VAR_variable_name or via the command line with a -var flag
# See: https://www.terraform.io/docs/language/values/variables.html#variable-definition-precedence

terraform plan -var "location=$RG_LOCATION" -var "acrRole=$ACR_ROLE" -var "adminPublicKey=$SSH_KEY" -var-file $WEBINAR_PARAMETERS -out tfplan

# Apply the plan file (e.g. tfplan) and provison the requested resources
#
# -auto-approve flag is optional but for automated environments you should use this flag to automatically deploy the resources without human/user interaction (i.e y/n input)
terraform apply -auto-approve tfplan