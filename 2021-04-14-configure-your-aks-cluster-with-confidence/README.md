# Configure your AKS cluster with confidence

This is the companion repo for the webinar "Configure your AKS cluster with confidence" on April 14th, 2021.

## Running the Bicep/Terraform Scripts

You may use the provided example ```run.sh``` bash scripts to deploy the required resources.

### Bicep:
```bash
cd bicep
bash run.sh
```

### Terraform:
```bash
cd terraform
bash run.sh
```

### Note:
- Each version of ```run.sh``` is meant to be an "idiomatic" example of how to provison your environment
- Each version contains examples on how to pass in parameters/variables view command line and via a params file ```{bicep: paramters.json, terraform: terraform.tfvars}```