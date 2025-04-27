# Defines the Terraform provider and version requirements for the Azure deployment
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"  # Specifies the Azure provider source
      version = ">= 3.0.0"           # Ensures a compatible provider version
    }
  }
}