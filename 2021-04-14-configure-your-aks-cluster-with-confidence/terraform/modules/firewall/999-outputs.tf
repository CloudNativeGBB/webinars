output "id" {
  value = azurerm_firewall.default.id
}

output "name" {
  value = azurerm_firewall.default.name
}

output "resource_group" {
  value = var.resource_group
}

output "ip_address" {
  value = azurerm_firewall.default.ip_configuration[0].private_ip_address
}