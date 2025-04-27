# Configures the Azure provider with authentication details for Terraform to manage Azure resources
provider "azurerm" {
  subscription_id            = var.subscription_id  # Azure subscription ID for authentication
  client_id                  = var.client_id        # Azure client ID for authentication
  client_secret              = var.client_secret    # Azure client secret for authentication
  tenant_id                  = var.tenant_id        # Azure tenant ID for authentication
  features {}
}