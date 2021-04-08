locals {
  prefix = var.prefix
  bind9conf = base64encode(templatefile("${path.module}/config/named.conf.options", {
    vnet_address_spaces = var.vnet_address_spaces
    forwarder_ips = ["168.63.129.16"]
  }))
}