data "azurerm_client_config" "current" {}

locals {
  prefix = var.prefix
  subnet_id = var.subnet_id
}