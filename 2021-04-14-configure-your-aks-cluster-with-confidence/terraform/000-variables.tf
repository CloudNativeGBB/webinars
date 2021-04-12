variable "prefix" {
	type = string
	description = "Value to prefix resource names with."
	default = "webinartf"
}

variable "location" {
	type = string
	description = "Default Azure Region"
	default = "canadacentral"
}