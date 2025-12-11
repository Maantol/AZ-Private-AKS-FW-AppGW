resource "azurerm_resource_group" "hub" {
  name     = "rg-${var.base_name}-${var.env}-${var.location}-hub"
  location = var.location_name_long
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-${var.base_name}-${var.env}-${var.location}-spoke-aks"
  location = var.location_name_long
}

resource "azurerm_resource_group" "loganalytics" {
  name     = "rg-${var.base_name}-${var.env}-${var.location}-loganalytics"
  location = var.location_name_long
}
