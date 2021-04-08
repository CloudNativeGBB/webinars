resource "azurerm_network_interface" "jumpbox" {
  name                = "jumpbox-nic-${var.index}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  enable_accelerated_networking = true
  
  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = "jumpbox${var.index}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  size                = var.sku
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.jumpbox.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = var.storage_account_type
    disk_size_gb = var.disk_size_gb
    diff_disk_settings {
      option = var.diff_disk_settings
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}