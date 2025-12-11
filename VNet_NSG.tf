#Create NSG for Jumpbox-VM: Allow only SSH from Bastion

resource "azurerm_network_security_group" "nsg-hub-bastion-gateway" {
  name                = "nsg-bas-${var.env}-${var.location}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  security_rule {
    name                       = "Allow-SSH-Bastion-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = [azurerm_subnet.hub-vnet-bastion.address_prefixes[0]]
    destination_address_prefix = "*"
  }

}

#Create NSG Association: Jumpbox-VM

resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = azurerm_subnet.hub-vnet-jumpbox-vm.id
  network_security_group_id = azurerm_network_security_group.nsg-hub-bastion-gateway.id
}

