#Create Azure Firewall

resource "azurerm_firewall" "fw" {
  name                = "afw-${var.env}-${var.location}-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  firewall_policy_id  = azurerm_firewall_policy.fw-policy.id
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name      = "afw-configuration"
    subnet_id = azurerm_subnet.hub-vnet-firewall.id

    public_ip_address_id = azurerm_public_ip.pip-firewall.id
  }
}

#Create Azure Firewall Policy

resource "azurerm_firewall_policy" "fw-policy" {
  name                = "afwp-${var.env}-${var.location}-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location

  dns {
    proxy_enabled = true
    servers       = ["168.63.129.16"]
  }
}

# Create Azure Firewall Rule Collection Group: Create Application and Network Rule Collection and assign them to policy

resource "azurerm_firewall_policy_rule_collection_group" "fw-rules" {
  name               = "afwprcg-${var.env}-${var.location}-hub"
  firewall_policy_id = azurerm_firewall_policy.fw-policy.id
  priority           = 100

  application_rule_collection {
    name     = "ApplicationRules"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "AllowAzureKubernetesService"
      source_addresses      = ["*"]
      destination_fqdn_tags = ["AzureKubernetesService"]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "AllowFqdnsForOsUpdates"
      source_addresses = ["*"]
      destination_fqdns = [
        "download.opensuse.org",
        "security.ubuntu.com",
        "azure.archive.ubuntu.com",
        "packages.microsoft.com",
        "snapcraft.io",
        "api.snapcraft.io",
        "motd.ubuntu.com"
      ]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "AllowImagesFqdns"
      source_addresses = ["*"]
      destination_fqdns = [
        "ghcr.io",
        "pkg-containers.githubusercontent.com",
        "docker.io",
        "auth.docker.io",
        "registry-1.docker.io",
        "production.cloudflare.docker.com"
      ]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }
    }
  }

  network_rule_collection {
    name     = "NetworkRules"
    priority = 200
    action   = "Allow"

    rule {
      name              = "Time"
      source_addresses  = ["*"]
      destination_ports = ["123"]
      destination_fqdns = ["ntp-ubuntu.com"]
      protocols         = ["UDP"]
    }

    rule {
      name                  = "APITCP_AzureCloud"
      source_addresses      = ["*"]
      destination_ports     = ["9000"]
      destination_addresses = ["AzureCloud.${var.location_name}"]
      protocols             = ["TCP"]
    }
    rule {
      name                  = "APIUDP_AzureCloud"
      source_addresses      = ["*"]
      destination_ports     = ["1194"]
      destination_addresses = ["AzureCloud.${var.location_name}"]
      protocols             = ["UDP"]
    }
  }
}
