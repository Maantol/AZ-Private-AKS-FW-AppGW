data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location_name_long
  include_preview = false
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                      = "aks01-${var.env}-${var.location}-aks"
  location                  = azurerm_resource_group.aks.location
  resource_group_name       = azurerm_resource_group.aks.name
  dns_prefix                = "aks01-${var.env}-${var.location}-aks"
  kubernetes_version        = data.azurerm_kubernetes_service_versions.current.latest_version
  private_cluster_enabled   = true
  private_dns_zone_id       = azurerm_private_dns_zone.k8s-dns-zone.id
  automatic_upgrade_channel = "stable"
  node_resource_group       = "rg-${var.base_name}-${var.env}-${var.location}-spoke-aks-nodepool"

  default_node_pool {
    name                 = "default"
    node_count           = 1
    vm_size              = "Standard_D2s_v6"
    auto_scaling_enabled = false
    vnet_subnet_id       = azurerm_subnet.spoke-vnet-aks.id
  }

  linux_profile {
    admin_username = "azureadmin"

    ssh_key {
      key_data = tls_private_key.tls.public_key_openssh
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    outbound_type       = "loadBalancer"
    load_balancer_sku   = "standard"
  }

  web_app_routing {
    dns_zone_ids             = []
    default_nginx_controller = "Internal"
  }


  depends_on = [
    azurerm_resource_group.aks,
    azurerm_virtual_network.spoke-aks-vnet,
    azurerm_user_assigned_identity.aks,
    azurerm_route_table.rt-aks,
    azurerm_subnet_route_table_association.rt-aks,
    azurerm_application_gateway.appgw
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "k8s_node_pool" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_D2s_v6"
  node_count            = 1
}