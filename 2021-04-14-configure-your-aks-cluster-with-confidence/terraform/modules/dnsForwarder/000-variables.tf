variable "prefix" {
  type = string
}

variable "vnet_address_spaces" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "resource_group" {
}

variable "sku" {
  type = string
  default = "Standard_A1_v2"
}

variable "admin_username" {
  type = string
  default = "raykao"
}