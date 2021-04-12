resource azurerm_log_analytics_workspace aks {
  name                = "${local.prefix}-${var.suffix}-logA-ws"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource azurerm_kubernetes_cluster dev {
  name                = "${local.prefix}-${var.suffix}-aks"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  
  dns_prefix          = "${local.prefix}-aks-cluster"
  
  kubernetes_version  = var.aks_settings.kubernetes_version
  private_cluster_enabled = false

  default_node_pool {
    name                = var.default_node_pool.name
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.min_count
    max_count           = var.default_node_pool.max_count
    vm_size             = var.default_node_pool.vm_size
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    type                = var.default_node_pool.type
    vnet_subnet_id      = var.subnet_id
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
  }

  identity {
    type = var.aks_settings.identity
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key					{
      key_data = file(var.aks_settings.ssh_key)
    }
  }

  network_profile {
    network_plugin     = var.aks_settings.network_plugin
    network_policy     = var.aks_settings.network_policy
    load_balancer_sku  = var.aks_settings.load_balancer_sku
    service_cidr       = var.aks_settings.service_cidr
    dns_service_ip     = var.aks_settings.dns_service_ip
    docker_bridge_cidr = var.aks_settings.docker_bridge_cidr
    outbound_type      = var.aks_settings.outbound_type
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
    }
    kube_dashboard {
      enabled = false
    }
  }
  
  sku_tier = var.aks_settings.sku_tier

  role_based_access_control {
    enabled = var.aks_settings.role_based_access_control_enabled

    azure_active_directory {
      managed = var.aks_settings.azure_active_directory_managed
      admin_group_object_ids = var.aks_settings.admin_group_object_ids
    }    
  }

}

resource azurerm_kubernetes_cluster_node_pool user {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.dev.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  mode                  = each.value.mode
  node_labels           = each.value.node_labels
  vnet_subnet_id        = var.subnet_id
  node_taints           = each.value.node_taints
}