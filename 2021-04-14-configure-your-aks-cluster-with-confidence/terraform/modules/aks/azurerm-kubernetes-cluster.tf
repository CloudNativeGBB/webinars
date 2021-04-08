resource azurerm_kubernetes_cluster dev {
  name                = "${local.prefix}-aks-cluster"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  
  dns_prefix          = "${local.prefix}-aks-cluster"
  
  kubernetes_version  = var.aks_settings.kubernetes_version
  private_cluster_enabled = var.aks_settings.private_cluster_enabled

  default_node_pool {
    name                = var.default_node_pool.name
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.min_count
    max_count           = var.default_node_pool.max_count
    vm_size             = var.default_node_pool.vm_size
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    type                = var.default_node_pool.type
    vnet_subnet_id      = var.subnet_id
  }

  identity {
    type = var.aks_settings.identity
  }
  # linux_profile {
  #   admin_username = var.aks_settings.admin_username
  #   ssh_key        = var.aks_settings.ssh_key
  # }

  network_profile {
    network_plugin     = var.aks_settings.network_plugin
    network_policy     = var.aks_settings.network_policy
    load_balancer_sku  = var.aks_settings.load_balancer_sku
    service_cidr       = var.aks_settings.service_cidr
    dns_service_ip     = var.aks_settings.dns_service_ip
    docker_bridge_cidr = var.aks_settings.docker_bridge_cidr
    outbound_type      = var.aks_settings.private_cluster_enabled == true ? "userDefinedRouting" : "loadBalancer"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
    kube_dashboard {
      enabled = false
    }
  }
  
  # role_based_access_control {
  #   enabled = true

  #   azure_active_directory {
  #     managed = true
  #     tenant_id = local.tenant_id

  #   }    
  # }

}

resource azurerm_kubernetes_cluster_node_pool user {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.dev.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  mode                  = "User"
  node_labels           = each.value.node_labels
  vnet_subnet_id        = var.subnet_id
  node_taints           = each.value.node_taints
}