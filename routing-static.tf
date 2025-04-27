# Creates a route table to direct traffic from the subnet to the internet
resource "azurerm_route_table" "cabbage_route_table" {
  name                          = "rt-${var.environment_name}-${var.location}-001"   # Name of the route table
  location                      = var.location                                      # Azure region for deployment
  resource_group_name           = azurerm_resource_group.cabbage_rg.name            # Resource group for the route table
  route {
    name                        = "internet"                                        # Name of the route
    address_prefix              = "0.0.0.0/0"                                       # Route all traffic
    next_hop_type               = "Internet"                                        # Direct to internet
  }
  route {
    name                        = "to-gcp"                                          # Name of the route
    address_prefix              = local.gcp_subnet_cidr                             # Destination range (GCP subnet)
    next_hop_type               = "VirtualNetworkGateway"                           # Direct to VPN Gateway
  }
}

# Associates the route table with the subnet for internet access
resource "azurerm_subnet_route_table_association" "cabbage_subnet_route" {
  subnet_id                     = azurerm_subnet.cabbage_subnet.id                  # Subnet to associate with the route table
  route_table_id                = azurerm_route_table.cabbage_route_table.id        # Route table to associate with the subnet
}