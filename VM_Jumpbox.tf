resource "azurerm_linux_virtual_machine" "jumpbox-vm" {
  name                = "vm-jumpbox-${var.env}-${var.location}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  size                = "Standard_D2s_v6"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.hub-vnet-nic-vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.tls.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = filebase64("./cloud-init/setup-vm.sh")

}