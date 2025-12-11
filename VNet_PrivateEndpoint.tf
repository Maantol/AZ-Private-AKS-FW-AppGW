# Create Private Endpoint: Make AKS Control Plane achievable

resource "azurerm_private_endpoint" "aks_control_plane" {
  name                = "pe-aks-${var.env}-${var.location}-spoke-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  subnet_id           = azurerm_subnet.spoke-vnet-aks.id

  private_service_connection {
    name                           = "psc-aks-api"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_kubernetes_cluster.k8s.id
    subresource_names              = ["management"]
  }

  private_dns_zone_group {
    name                 = "psc-aks-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.k8s-dns-zone.id]
  }
}
