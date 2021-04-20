resource "azurerm_public_ip" "firewall" {
  name                = "${var.prefix}-${var.suffix}-afw-pip"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.prefix}-${var.suffix}-afw-pip"
}

resource "azurerm_firewall" "default" {
  name                = "${var.prefix}-${var.suffix}-primaryFirewall"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                 = "primary"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}