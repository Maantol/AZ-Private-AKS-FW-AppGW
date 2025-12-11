data "azurerm_subscription" "current" {
}

# Create Role-Assignment for VM. VM is SystemAssigned

resource "azurerm_role_assignment" "vm-role-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_virtual_machine.jumpbox-vm.identity[0].principal_id
}

# Create User Identity: AKS"

resource "azurerm_user_assigned_identity" "aks" {
  name                = "uai-${var.env}-${var.location}-spoke-aks"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
}

# Assign required roles


resource "azurerm_role_assignment" "dns-contributor" {
  scope                = azurerm_private_dns_zone.k8s-dns-zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}


resource "azurerm_role_assignment" "network-contributor" {
  scope                = azurerm_virtual_network.spoke-aks-vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "role-reader" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
