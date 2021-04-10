module "aks" {
	depends_on = [
		module.firewall,
		module.vpn,
		azurerm_subnet_route_table_association.aks,
		azurerm_firewall_application_rule_collection.aks,
		azurerm_firewall_application_rule_collection.azureMonitor,
		azurerm_firewall_application_rule_collection.updates,
		azurerm_firewall_network_rule_collection.ntp
	]

	source 			= "./modules/aks"

	prefix 			= local.prefix
	subnet_id 		= azurerm_subnet.aks.id
	resource_group 	= azurerm_resource_group.default
	log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

	aks_settings = {
    	kubernetes_version		= null
		private_cluster_enabled = true
		identity 				= "SystemAssigned"
		outbound_type			= "userDefinedRouting"
		network_plugin			= "azure"
		network_policy			= "calico"
		load_balancer_sku		= "standard"
		service_cidr			= "172.16.0.0/22"
		dns_service_ip 			= "172.16.0.10"
		docker_bridge_cidr 		= "172.16.0.1/16"
	}

	default_node_pool = {
		name = "defaultnp01"
		enable_auto_scaling = true
		node_count = 2
		min_count = 2
		max_count = 5
		vm_size = "Standard_D2s_v3"
		type    = "VirtualMachineScaleSets"
		os_disk_size_gb = 30
		only_critical_addons_enabled = true
	}
}