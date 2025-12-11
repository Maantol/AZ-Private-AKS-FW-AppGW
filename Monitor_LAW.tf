#Create Log Analytics Workspace: Store Logging.

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.env}-${var.location}-loganalytics"
  location            = azurerm_resource_group.loganalytics.location
  resource_group_name = azurerm_resource_group.loganalytics.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
