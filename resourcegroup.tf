# Creates a resource group to contain all Azure resources
resource "azurerm_resource_group" "cabbage_rg" {
  name     = "${local.resource_group_name}001"  # Name of the resource group
  location = var.location                       # Azure region for deployment
}