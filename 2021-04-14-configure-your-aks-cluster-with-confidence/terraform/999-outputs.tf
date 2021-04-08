# output vpn_fqdn {
#   value = azurerm_public_ip.vpngateway.fqdn
# }

# output "vpn_id" {
#   value = module.vpn.gateway.id
# }

output "client_cert_password" {
  value = local.cert_password
}