resource "azurerm_public_ip" "vpngateway" {
	name                = "${local.prefix}-vpn-pip"
	resource_group_name = var.resource_group.name
	location            = var.resource_group.location
	allocation_method   = "Static"
	sku 				= "Standard"
  domain_name_label = "${local.prefix}-vpn"
}

resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  rsa_bits = 2048
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.ca.private_key_pem

  is_ca_certificate = true

  subject {
    common_name  = "hub.raykao.com"
    organization = "Ray Kao"
  }

  dns_names = [ azurerm_public_ip.vpngateway.fqdn ]

  validity_period_hours = 4380

  allowed_uses = [
    "key_encipherment",
    "data_encipherment",
    "digital_signature",
    "server_auth",
    "cert_signing",
    "ipsec_tunnel",
    "ipsec_user",
    "crl_signing"
  ]
}

resource "local_file" "ca_pem" {
  filename = "certs/${terraform.workspace}/caCert.pem"
  content  = tls_self_signed_cert.ca.cert_pem
  file_permission = "0640"
}

resource "null_resource" "cert_encode" {
  depends_on =  [ local_file.ca_pem ]
  
  provisioner "local-exec" {
      command = "openssl x509 -in certs/${terraform.workspace}/caCert.pem -outform der | if [[ \"$(uname)\" = \"Darwin\" ]]; then base64 > certs/${terraform.workspace}/caCert.der; else base64 -w0 > certs/${terraform.workspace}/caCert.der; fi"
  }
}

data "local_file" "ca_der" {
  filename = "certs/${terraform.workspace}/caCert.der"
  depends_on = [
    null_resource.cert_encode
  ]
}

resource "azurerm_virtual_network_gateway" "default" {
  name                = "${local.prefix}-vpn"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku = var.vpn_sku
  generation = var.vpn_sku == "VpnGw1AZ" || var.vpn_sku == "VpnGw1" || var.vpn_sku == "Basic" ? "Generation1" : "Generation2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpngateway.id
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  vpn_client_configuration {
    address_space = ["172.16.201.0/24"]

    root_certificate {
      name = "VPNRoot"
      public_cert_data = data.local_file.ca_der.content
    }
  }
}