resource "azurerm_public_ip" "jumpbox" {
  name                = "${var.prefix}-${var.suffix}-jumpbox"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  allocation_method   = "Static"
  domain_name_label = "${var.prefix}-${var.suffix}-jumpbox"
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "${var.prefix}-${var.suffix}-jumpbox"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.jumpbox.id
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  # depends_on = [ azurerm_linux_virtual_machine_scale_set.k3s-masters ]
  name                = "${var.prefix}-${var.suffix}-jumpbox"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  size                = "Standard_F2"
  admin_username      = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_key)
  }

  network_interface_ids = [
    azurerm_network_interface.jumpbox.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}