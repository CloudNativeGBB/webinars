# Login to your Azure account
# az login

# Plan and deploy your Terraform template
terraform init
terraform plan -out tfplan
terraform apply -auto-approve tfplan