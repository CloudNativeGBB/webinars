resource "azurerm_resource_group" "default" {
  name = "${local.prefix}-${local.suffix}"
  location = var.location
}