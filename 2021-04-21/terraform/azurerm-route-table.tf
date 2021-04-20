resource "azurerm_route_table" "default" {
  name                = "defaultRouteTable"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_route" "default" {
  name                = "defaultRoute"
  resource_group_name = azurerm_resource_group.default.name
  route_table_name    = azurerm_route_table.default.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = module.firewall.ip_address
}

resource "azurerm_subnet_route_table_association" "aks" {
	subnet_id = azurerm_subnet.aks.id
	route_table_id = azurerm_route_table.default.id
}