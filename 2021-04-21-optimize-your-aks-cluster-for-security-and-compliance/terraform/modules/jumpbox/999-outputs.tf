output public_ip {
	value = azurerm_public_ip.jumpbox.ip_address
}

output fqdn {
	value = azurerm_public_ip.jumpbox.fqdn
}