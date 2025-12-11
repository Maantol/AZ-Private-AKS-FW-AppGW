# Create UDR: Forward all egress traffic from Spoke (AKS) to Firewall (Private IP) 

resource "azurerm_route_table" "rt-aks" {
  name                = "rt-${var.env}-${var.location}-spoke-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  route {
    name                   = "RouteToAFW"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

# Create RT Association: UDR AKS
resource "azurerm_subnet_route_table_association" "rt-aks" {
  subnet_id      = azurerm_subnet.spoke-vnet-aks.id
  route_table_id = azurerm_route_table.rt-aks.id

  depends_on = [azurerm_firewall.fw]
}
