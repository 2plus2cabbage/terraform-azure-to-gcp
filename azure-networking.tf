# Defines Azure networking values for IPSEC connection
locals {
  vnet_cidr           = "10.4.0.0/16"                               # Address space for the VNet
  vm_subnet_cidr      = "10.4.1.0/24"                               # The private network on the Azure side for the Windows VM
  gateway_subnet_cidr = "10.4.0.0/24"                               # CIDR for the GatewaySubnet
}

# Creates a virtual network (VNet) to host the subnet and resources
resource "azurerm_virtual_network" "cabbage_vnet" {
  name                = "${local.vnet_name}1040016"                 # Name of the VNet
  address_space       = [local.vnet_cidr]                           # Address space for the VNet
  location            = var.location                                # Azure region for deployment
  resource_group_name = azurerm_resource_group.cabbage_rg.name      # Resource group for the VNet
}

# Creates a subnet within the VNet for the Windows VM
resource "azurerm_subnet" "cabbage_subnet" {
  name                 = "${local.subnet_name_prefix}1041024"       # Name of the subnet
  resource_group_name  = azurerm_resource_group.cabbage_rg.name     # Resource group for the subnet
  virtual_network_name = azurerm_virtual_network.cabbage_vnet.name  # VNet for the subnet
  address_prefixes     = [local.vm_subnet_cidr]                     # Address prefix for the subnet
}