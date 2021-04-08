variable "prefix" {
  type = string
}

variable "index" {
  type = number
  default = 1
}

variable "subnet_id" {
  type = string
}

variable "resource_group" {
}

variable "sku" {
  type = string
  default = "Standard_D4s_v3"
}

variable "instances" {
  type = number
  default = 1
}

variable "admin_username" {
  type = string
  default = "raykao"
}

variable "caching" {
  type = string
  default = "ReadOnly"
}

variable "storage_account_type" {
  type = string
  default = "Standard_LRS"
}

variable "disk_size_gb" {
  type = string
  default = "100"
}

variable "diff_disk_settings" {
  type = string
  default = "Local"
}