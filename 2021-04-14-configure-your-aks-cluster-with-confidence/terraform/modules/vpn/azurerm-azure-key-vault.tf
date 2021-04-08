resource "azurerm_key_vault" "vpn" {
  name                        = "${replace(local.prefix, "-", "")}vpnkeyvault"
  location                    = var.resource_group.location
  resource_group_name         = var.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "default" {
  key_vault_id = azurerm_key_vault.vpn.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [ 
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
   ]

   key_permissions = [
     "Backup",
     "Create",
     "Decrypt",
     "Delete",
     "Encrypt",
     "Get",
     "Import",
     "List",
     "Purge",
     "Recover",
     "Restore",
     "Sign",
     "UnwrapKey",
     "Update",
     "Verify",
     "WrapKey"
   ]

   secret_permissions = [
     "Backup",
     "Delete",
     "DeleteSAS",
     "Get",
     "GetSAS",
     "List",
     "ListSAS",
     "Purge",
     "Recover",
     "RegenerateKey",
     "Restore",
     "Set",
     "SetSAS",
     "Update"
   ]
}

resource "azurerm_key_vault_secret" "vpn-ca-private-key" {
  name = "vpn-ca-private-key"
  value = base64encode(tls_private_key.ca.private_key_pem)
  key_vault_id = azurerm_key_vault.vpn.id
}

resource "azurerm_key_vault_secret" "vpn-ca-root-certificate" {
  name = "vpn-ca-root-certificate"
  value = base64encode(tls_self_signed_cert.ca.cert_pem)
  key_vault_id = azurerm_key_vault.vpn.id
}