module "aks" {
	source 			= "./modules/aks"

	prefix 			= local.prefix
	suffix			= var.suffix
	subnet_id 		= azurerm_subnet.aks.id
	resource_group 	= azurerm_resource_group.default
	acrRole			= var.acrRole

	aks_settings = {
    	kubernetes_version		= var.kubernetes_version
		identity 				= "SystemAssigned"
		outbound_type			= "loadBalancer"
		network_plugin			= "azure"
		network_policy			= "calico"
		load_balancer_sku		= "standard"
		service_cidr			= "172.16.0.0/22"
		dns_service_ip 			= "172.16.0.10"
		docker_bridge_cidr 		= "172.16.4.1/22"
		sku_tier				= "Paid"
		role_based_access_control_enabled = true
		azure_active_directory_managed = true
		admin_group_object_ids  = var.admin_group_object_ids
		ssh_key					= var.adminPublicKey
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

	user_node_pools = {
		usernp1 = {
			vm_size = "Standard_D4s_v3"
			node_count = 3
			node_labels = null
			node_taints = []
			mode = "User"
		}
	}
}