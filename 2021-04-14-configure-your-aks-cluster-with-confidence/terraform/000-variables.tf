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

variable "kubernetes_version" {
  type = string
  description = "K8s Version"
  default = "1.18.14"
}

variable "admin_group_object_ids" {
  type = list(string)
  description = "AAD GroupID used as K8s Admin Group"
  default = []
}