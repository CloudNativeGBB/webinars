module "jumpbox" {
	depends_on = [
		module.firewall
	]

	source = "./modules/jumpbox"

	prefix = local.prefix
	subnet_id = azurerm_subnet.jumpbox.id
	resource_group = azurerm_resource_group.default
}