resource "azurerm_virtual_network" "default" {
  name = "${azurerm_resource_group.default.name}-vnet"
  location = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.4.0/22"]
  # enforce_private_link_service_network_policies = false  
  enforce_private_link_endpoint_network_policies = false
}
