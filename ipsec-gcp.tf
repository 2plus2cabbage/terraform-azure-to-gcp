# Creates a Local Network Gateway representing the GCP side
resource "azurerm_local_network_gateway" "gcp_lng" {
  name                      = "${local.gw_name_prefix}gcp-lng"                          # Name of the Local Network Gateway
  location                  = var.location                                              # Azure region for deployment
  resource_group_name       = azurerm_resource_group.cabbage_rg.name                    # Resource group for the Local Network Gateway
  gateway_address           = local.gcp_vpn_ip                                          # GCP VPN Gateway public IP
  address_space             = [local.gcp_subnet_cidr]                                   # GCP subnet CIDR for traffic
}

# Creates the IPSEC connection between Azure and GCP
resource "azurerm_virtual_network_gateway_connection" "azure_to_gcp" {
  name                       = "${local.gw_name_prefix}to-gcp"                          # Name of the connection
  location                   = var.location                                             # Azure region for deployment
  resource_group_name        = azurerm_resource_group.cabbage_rg.name                   # Resource group for the connection
  type                       = "IPsec"                                                  # Connection type (IPsec)
  virtual_network_gateway_id = azurerm_virtual_network_gateway.azure_vpn_gateway.id     # Azure VPN Gateway
  local_network_gateway_id   = azurerm_local_network_gateway.gcp_lng.id                 # GCP Local Network Gateway
  shared_key                 = var.shared_secret_gcp                                    # Shared secret for IPSEC (must match GCP)
}