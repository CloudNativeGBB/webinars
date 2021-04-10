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