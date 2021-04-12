variable "prefix" {
  type = string
}

variable "suffix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "resource_group" {
}

variable "acrRole" {
  type = string
  description = "ACR Role Permission for AKS"
  default	= "AcrPull"
}

variable aks_settings {
	type = object({
		kubernetes_version		= string
		identity 				= string
		outbound_type			= string
		network_plugin			= string
		network_policy			= string
		load_balancer_sku		= string
		service_cidr			= string
		dns_service_ip 			= string
		docker_bridge_cidr 		= string
		sku_tier				= string
		role_based_access_control_enabled = bool
		azure_active_directory_managed = bool
		admin_group_object_ids  = list(string)
		ssh_key					= string
	})
	default = {
		kubernetes_version		= null
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
		admin_group_object_ids  = [null]
		ssh_key					= "~/.ssh/id_rsa.pub"
		# admin_username			= "azureuser"
		# ssh_key					= null
	}
}

variable default_node_pool {
	type = object({
		name = string
		enable_auto_scaling = bool
		node_count = number
		min_count = number
		max_count = number
		vm_size = string
		type    = string
		os_disk_size_gb = number
		only_critical_addons_enabled = bool
	})
	
	default = {
		name = "defaultnp"
		enable_auto_scaling = true
		node_count = 2
		min_count = 2
		max_count = 5
		vm_size = "Standard_D4s_v3"
		type    = "VirtualMachineScaleSets"
		os_disk_size_gb = 30
		only_critical_addons_enabled = true
	}
}

variable user_node_pools {
	type = map(object({
		vm_size = string
		node_count = number
		node_labels = map(string)
		node_taints = list(string)
		mode = string
	}))
	
	default = {
		"usernp1" = {
			vm_size = "Standard_D4s_v3"
			node_count = 3
			node_labels = null
			node_taints = []
			mode = "User"
		}
	}
}