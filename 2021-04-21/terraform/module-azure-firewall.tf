module "firewall" {
	source 			= "./modules/azure-firewall"
	
	prefix = local.prefix
	suffix = local.suffix

	subnet_id 		= azurerm_subnet.firewall.id
	resource_group 	= azurerm_resource_group.default
}

resource azurerm_firewall_application_rule_collection "aks" {
  name                = "aksRequiredRules${local.suffix}"
  azure_firewall_name = module.firewall.name
  resource_group_name = module.firewall.resource_group.name
  priority            = 120
  action              = "Allow"

  rule {
    name = "updateInfraRules"

    source_addresses = concat([],azurerm_virtual_network.default.address_space)

    target_fqdns = [
      "*.hcp.${module.firewall.resource_group.location}.azmk8s.io",
      "mcr.microsoft.com",
      "*.cdn.mcr.io",
      "*.data.mcr.microsoft.com",
      "management.azure.com",
      "login.microsoftonline.com",
      "dc.services.visualstudio.com",
      "*.ods.opinsights.azure.com",
      "*.oms.opinsights.azure.com",
      "*.monitoring.azure.com",
      "packages.microsoft.com",
      "acs-mirror.azureedge.net",
      "azure.archive.ubuntu.com",
      "security.ubuntu.com",
      "changelogs.ubuntu.com",
      "launchpad.net",
      "ppa.launchpad.net",
      "keyserver.ubuntu.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }

    protocol {
      port = "80"
      type = "Http"
    }
  }
}

resource azurerm_firewall_application_rule_collection "azureMonitor" {
  name                = "azureMonitorRequiredRules${local.suffix}"
  azure_firewall_name = module.firewall.name
  resource_group_name = module.firewall.resource_group.name
  priority            = 110
  action              = "Allow"

  rule {
    name = "azureMonitorRules"

    source_addresses = concat([],azurerm_virtual_network.default.address_space)

    target_fqdns = [
      "dc.services.visualstudio.com",
      "*.ods.opinsights.azure.com",
      "*.oms.opinsights.azure.com",
      "*.monitoring.azure.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}


resource "azurerm_firewall_network_rule_collection" "ntp" {
  name                = "ntpRule${local.suffix}"
  azure_firewall_name = module.firewall.name
  resource_group_name = module.firewall.resource_group.name
  priority            = 150
  action              = "Allow"

  rule {
    name = "ubuntuNTP"

    source_addresses = azurerm_subnet.aks.address_prefixes

    destination_ports = [
      "123",
    ]

    destination_addresses = [
      "*"
    ]

    protocols = [
      "UDP",
    ]
  }
}

resource azurerm_firewall_application_rule_collection "updates" {
  name                = "ubuntuUpdateInfrastructure${local.suffix}"
  azure_firewall_name = module.firewall.name
  resource_group_name = module.firewall.resource_group.name
  priority            = 400
  action              = "Allow"

  rule {
    name = "updateInfraRules"

    source_addresses = concat([],azurerm_virtual_network.default.address_space)

    target_fqdns = [
      "azure.archive.ubuntu.com",
      "security.ubuntu.com",
      "changelogs.ubuntu.com",
      "launchpad.net",
      "ppa.launchpad.net",
      "keyserver.ubuntu.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }

    protocol {
      port = "80"
      type = "Http"
    }
  }
}