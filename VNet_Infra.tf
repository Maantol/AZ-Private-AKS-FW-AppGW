#Create: Hub-Spoke Vnet

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "vnet-${var.env}-${var.location}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_vnet_cidr]
}

resource "azurerm_virtual_network" "spoke-aks-vnet" {
  name                = "vnet-${var.env}-${var.location}-spoke-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = [var.spoke_aks_vnet_cidr]
}

#Create Hub subnets: Jumpbox, Bastion, Gateway, Firewall

resource "azurerm_subnet" "hub-vnet-jumpbox-vm" {
  name                 = "snet-jumpbox${var.env}-${var.location}-hub"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}
resource "azurerm_subnet" "hub-vnet-bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "hub-vnet-firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#Create Spoke (AKS) subnets: AKS, Applicatino Gateway, Load Balancer (Nginx).

resource "azurerm_subnet" "spoke-vnet-aks" {
  name                 = "snet-aks-${var.env}-${var.location}-spoke-aks"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.spoke-aks-vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "snet-appgw-${var.env}-${var.location}-spoke-aks"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.spoke-aks-vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "snet-aks-lb" {
  name                 = "snet-lb-${var.env}-${var.location}-spoke-aks"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.spoke-aks-vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}


#Create NIC: VM (Jumpbox) NIC

resource "azurerm_network_interface" "hub-vnet-nic-vm" {
  name                = "nic-vm-${var.env}-${var.location}-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location

  ip_configuration {
    name                          = "hub-vnet-nic"
    subnet_id                     = azurerm_subnet.hub-vnet-jumpbox-vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Create Public IP for Hub: Bastion, Firewall

resource "azurerm_public_ip" "pip-bastion" {
  name                = "pip-bas-${var.env}-${var.location}-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip-firewall" {
  name                = "pip-fw-${var.env}-${var.location}-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Create Public IP for Spoke (AKS): Application Gateway

resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw-${var.env}-${var.location}-spoke-aks"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Create VNet Peering: Hub-Spoke virtual networks

resource "azurerm_virtual_network_peering" "hub-spoke-peering" {
  name                         = "peering-hub-to-spoke${var.env}-${var.location}-hub"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke-aks-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on = [
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network.spoke-aks-vnet
  ]
}

resource "azurerm_virtual_network_peering" "spoke-hub-peering" {
  name                         = "peering-spoke-to-hub-${var.env}-${var.location}-hub"
  resource_group_name          = azurerm_resource_group.aks.name
  virtual_network_name         = azurerm_virtual_network.spoke-aks-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on = [
    azurerm_virtual_network.spoke-aks-vnet,
    azurerm_virtual_network.hub-vnet
  ]
}