# Public IP for Virtual Network Gateway
resource "azurerm_public_ip" "azure_vpn_gw_ip" {
  name                            = "${local.public_ip_prefix}vng-001"                                # Name of the public IP
  location                        = var.location                                                      # Azure region for deployment
  resource_group_name             = azurerm_resource_group.cabbage_rg.name                            # Resource group for the public IP
  allocation_method               = "Static"                                                          # Static allocation for the public IP
  sku                             = "Standard"                                                        # SKU for the public IP
}

# Gateway Subnet for the Virtual Network Gateway
resource "azurerm_subnet" "gateway_subnet" {
  name                            = "GatewaySubnet"                                                   # Name of the subnet (required name for VPN Gateway)
  resource_group_name             = azurerm_resource_group.cabbage_rg.name                            # Resource group for the subnet
  virtual_network_name            = azurerm_virtual_network.cabbage_vnet.name                         # VNet for the subnet
  address_prefixes                = [local.gateway_subnet_cidr]                                       # Address prefix for the subnet
}

# Virtual Network Gateway for IPSEC connections
resource "azurerm_virtual_network_gateway" "azure_vpn_gateway" {
  name                            = "${local.gw_name_prefix}vng-001"                                  # Name of the VPN Gateway
  location                        = var.location                                                      # Azure region for deployment
  resource_group_name             = azurerm_resource_group.cabbage_rg.name                            # Resource group for the VPN Gateway
  type                            = "Vpn"                                                             # Type of gateway (VPN)
  vpn_type                        = "RouteBased"                                                      # VPN type (RouteBased for IPSEC)
  sku                             = "VpnGw1"                                                          # SKU for the VPN Gateway
  ip_configuration {
    name                          = "vnetGatewayConfig"                                               # Name of the IP configuration
    public_ip_address_id          = azurerm_public_ip.azure_vpn_gw_ip.id                              # Public IP for the VPN Gateway
    private_ip_address_allocation = "Dynamic"                                                         # Dynamic private IP allocation
    subnet_id                     = azurerm_subnet.gateway_subnet.id                                  # Subnet for the VPN Gateway
  }
}

# Output Azure VPN Gateway Public IP
output "azure_vpn_ip" {
  value                           = azurerm_public_ip.azure_vpn_gw_ip.ip_address                      # Public IP of the Azure VPN Gateway
  description                     = "Public IP of the Azure VPN Gateway for IPSEC configuration"      # Description of the output
}