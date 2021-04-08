resource "azurerm_resource_group" "default" {
  name = "${local.prefix}-${var.location}"
  location = var.location
}