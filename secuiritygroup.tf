# Creates a network security group to control traffic to the subnet
resource "azurerm_network_security_group" "cabbage_nsg" {
  name                          = "${local.security_group_name_prefix}001"        # Name of the network security group
  location                      = var.location                                    # Azure region for deployment
  resource_group_name           = azurerm_resource_group.cabbage_rg.name          # Resource group for the NSG
  security_rule {
    name                        = "rdp"                                           # Name of the security rule
    priority                    = 100                                             # Rule priority
    direction                   = "Inbound"                                       # Direction of traffic
    access                      = "Allow"                                         # Allow traffic
    protocol                    = "Tcp"                                           # Protocol for RDP
    source_port_range           = "*"                                             # Source port range
    destination_port_range      = "3389"                                          # Destination port for RDP
    source_address_prefix       = var.my_public_ip                                # Source IP for RDP access
    destination_address_prefix  = "*"                                             # Destination IP range
  }
  security_rule {
    name                        = "icmp-from-gcp"                                 # Name of the security rule
    priority                    = 110                                             # Rule priority (must be unique, higher than RDP)
    direction                   = "Inbound"                                       # Direction of traffic
    access                      = "Allow"                                         # Allow traffic
    protocol                    = "Icmp"                                          # Protocol for ICMP
    source_port_range           = "*"                                             # Source port range
    destination_port_range      = "*"                                             # Destination port range
    source_address_prefix       = local.gcp_subnet_cidr                           # Source IP range (GCP subnet)
    destination_address_prefix  = "*"                                             # Destination IP range
  }
}

# Associates the network security group with the subnet
resource "azurerm_subnet_network_security_group_association" "cabbage_nsg_subnet" {
  subnet_id                     = azurerm_subnet.cabbage_subnet.id                # Subnet to associate with the NSG
  network_security_group_id     = azurerm_network_security_group.cabbage_nsg.id   # NSG to associate with the subnet
}