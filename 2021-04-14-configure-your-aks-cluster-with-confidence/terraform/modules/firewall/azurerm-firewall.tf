resource "azurerm_public_ip" "firewall" {
  name                = "${local.prefix}-firewall-pip"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label = "${local.prefix}-firewall"
}

resource "azurerm_firewall" "default" {
  name                = "${local.prefix}-firewall"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  ip_configuration {
    name                 = "primary"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}