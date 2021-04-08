variable "prefix" {
	type = string
	description = "Value to prefix resource names with."
	default = "webinar"
}

variable "location" {
	type = string
	description = "Default Azure Region"
	default = "canadacentral"
}

variable "vpn_sku" {
  type = string
  default = "VpnGw1AZ"
}

variable "domain" {
  type = string
  default = "azuregbb.com"
}