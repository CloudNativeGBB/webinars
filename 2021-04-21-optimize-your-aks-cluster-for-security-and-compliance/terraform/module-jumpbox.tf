module jumpbox {
	source = "./modules/jumpbox"

	prefix = local.prefix
	suffix = local.suffix

	resource_group = azurerm_resource_group.default
	subnet_id = azurerm_subnet.jumpbox.id
	admin_ssh_key = var.adminPublicKey
}