variable "prefix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "resource_group" {
}

variable "vpn_sku" {
  type = string
  default = "VpnGw1AZ"
}