variable "prefix" {
	type = string
	description = "Value to prefix resource names with."
	default = "webinartf"
}

variable "suffix" {
  type = string
	description = "Value used for resource names suffix."
	default = "randomsuffix"
}

variable "vnetPrefix" {
  type = string
  description = "Azure VNET CIDR Prefix/range"
  default =  "10.0.0.0/16"
}

variable "kubernetes_version" {
  type = string
  description = "K8s Version"
  default = "1.18.14"
}

variable "adminUsername" {
  type = string
  description = "Admin User name for k8s work nodes/agents"
  default = "azureuser"
}

variable "adminPublicKey" {
  type = string
  description = "SSH Public Key for remote login to nodes"
  default = "~/.ssh/id_rsa.pub"
}

variable "location" {
	type = string
	description = "Default Azure Region"
	default = "eastus2"
}

variable "admin_group_object_ids" {
  type = list(string)
  description = "AAD GroupID used as K8s Admin Group"
  default = []
}

variable "acrRole" {
  type = string
  description = "ACR role permission name for AKS - default: 'AcrPull'"
  default = "AcrPull"
}