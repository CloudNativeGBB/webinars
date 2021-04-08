resource "azurerm_private_dns_zone" "hub" {
  name = "${var.location}.${var.domain}"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "hubDnsLink"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.hub.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled = true
}