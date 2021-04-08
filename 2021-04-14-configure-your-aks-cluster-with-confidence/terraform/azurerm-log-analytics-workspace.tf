resource azurerm_log_analytics_workspace aks {
  name                = "${local.prefix}-logA-ws"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}