#Create Private DNS resolver: Hub"

resource "azurerm_private_dns_resolver" "dns-resolver" {
  name                = "dns-res-${var.env}-${var.location}-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  virtual_network_id  = azurerm_virtual_network.hub-vnet.id
}

# Create Private DNS Zone: AKS

resource "azurerm_private_dns_zone" "k8s-dns-zone" {
  name                = "privatelink.${var.location_name}.azmk8s.io"
  resource_group_name = azurerm_resource_group.hub.name
}

#Create Private DNS Zone Virtual Network Link: Hub, Spoke

resource "azurerm_private_dns_zone_virtual_network_link" "k8s-link-hub" {
  name                  = "vnl-hub-aks-${var.env}-${var.location}-hub"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.k8s-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "k8s-link-spoke" {
  name                  = "vnl-spokes-aks-${var.env}-${var.location}-hub"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.k8s-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.spoke-aks-vnet.id
}
