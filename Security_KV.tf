#Create Key Vault: Jumpbox SSH-key


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "vault-${var.env}-${var.location}-hub-${random_integer.suffix.result}"
  location                    = azurerm_resource_group.hub.location
  resource_group_name         = azurerm_resource_group.hub.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false

  sku_name = "standard"

  rbac_authorization_enabled = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Purge"
    ]
  }

}

resource "azurerm_key_vault_secret" "vm-privatekey" {
  name         = "secret-${var.env}-${var.location}-jumpbox-vm"
  value        = tls_private_key.tls.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id
}