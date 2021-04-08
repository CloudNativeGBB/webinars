output "ca_cert" {
	value = tls_self_signed_cert.ca.cert_pem
}

output "ca_private_key" {
	value = {
		algorithm = tls_private_key.ca.algorithm
	}
}

output "gateway" {
  value = azurerm_virtual_network_gateway.default
}

output "key_vault_id" {
	value = azurerm_key_vault.vpn.id
}