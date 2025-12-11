#Create Bastion host: Access Jumpbox VM from Azure Portal or output private SSH-key to manage AKS Control Plane

resource "azurerm_bastion_host" "bastion-hub" {
  name                = "bas-${var.env}-${var.location}-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  sku                 = "Standard"
  tunneling_enabled   = true
  ip_connect_enabled  = true

  ip_configuration {
    name                 = "bastion_ip_configuration"
    subnet_id            = azurerm_subnet.hub-vnet-bastion.id
    public_ip_address_id = azurerm_public_ip.pip-bastion.id
  }

}