variable "prefix" {
  type = string
}

variable "suffix" {
  type = string
}

variable "admin_username" {
  type = string
  default = "azureuser"
}

variable "admin_ssh_key" {
  type = string
  default = ""
}

variable "resource_group" {
  
}

variable "subnet_id" {
  type = string
}