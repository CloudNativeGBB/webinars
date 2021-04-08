module "vpn" {
	depends_on = [
		module.firewall
	]

	source = "./modules/vpn"
	
	prefix = local.prefix
	subnet_id = azurerm_subnet.vpngateway.id
	resource_group = azurerm_resource_group.default
	vpn_sku = var.vpn_sku
}

# data "azurerm_key_vault_secret" "vpn-ca-private-key" {
#   name         = "vpn-ca-private-key"
#   key_vault_id = module.vpn.key_vault_id
# }

# data "azurerm_key_vault_secret" "vpn-ca-root-certificate" {
#   name         = "vpn-ca-root-certificate"
#   key_vault_id = module.vpn.key_vault_id
# }

# resource "tls_private_key" "client_cert" {
# 	algorithm = "RSA"
# 	rsa_bits  = "2048"
# }

# resource "tls_cert_request" "client_cert" {
# 	key_algorithm = tls_private_key.client_cert.algorithm
# 	private_key_pem = tls_private_key.client_cert.private_key_pem
# 	# dns_names = [ azurerm_public_ip.vpn_ip.domain_name_label ]
# 	subject {
# 		common_name  = "ClientOpenVPN"
# 		organization = "dev env"
# 	}
# }

# resource "tls_locally_signed_cert" "client_cert" {
# 	cert_request_pem = tls_cert_request.client_cert.cert_request_pem
# 	ca_key_algorithm = module.vpn.ca_private_key.algorithm
# 	ca_private_key_pem = data.azurerm_key_vault_secret.vpn-ca-private-key.value
# 	ca_cert_pem = data.azurerm_key_vault_secret.vpn-ca-root-certificate.value
# 	validity_period_hours = 43800
# 	allowed_uses = [
# 		"key_encipherment",
# 		"digital_signature",
# 		"server_auth",
# 		"key_encipherment",
# 		"client_auth",
# 	]
# }

# resource "local_file" "client_key" {
#   filename = "certs/${terraform.workspace}/clientKey.pem"
#   content  = tls_private_key.client_cert.private_key_pem
#   file_permission = "0640"
# }

# resource "local_file" "client_pem" {
#   filename = "certs/${terraform.workspace}/clientCert.pem"
#   content  = tls_locally_signed_cert.client_cert.cert_pem
#   file_permission = "0640"
# }

# resource "null_resource" "client_cert_package" {
#   depends_on =  [ local_file.ca_pem ]
  
#   provisioner "local-exec" {
#       command = "openssl pkcs12 -in certs/clientCert.pem -inkey certs/${terraform.workspace}/clientKey.pem -certfile certs/caCert.pem -export -out certs/clientCert.p12 -password pass:${local.cert_password}"
#   }
# }