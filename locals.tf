locals {
  vnet_name                      = "vnet-${var.environment_name}-${var.location}-"          # Prefix for VNet name
  resource_group_name            = "rg-${var.environment_name}-${var.location}-"            # Prefix for resource group name
  security_group_name_prefix     = "nsg-${var.environment_name}-${var.location}-"           # Prefix for network security group name
  subnet_name_prefix             = "snet-${var.environment_name}-${var.location}-"          # Prefix for subnet name
  network_interface_prefix       = "nic-${var.environment_name}-${var.location}-"           # Prefix for network interface name
  private_ip_prefix              = "ip-${var.environment_name}-${var.location}-"            # Prefix for private IP configuration name
  public_ip_prefix               = "pip-${var.environment_name}-${var.location}-"           # Prefix for public IP name
  windows_name_prefix            = "vm-${var.environment_name}-${var.location}-windows-"    # Prefix for Windows VM name
  admin_username                 = "${var.environment_name}admin"                           # Admin username for the Windows VM
  diskos_name                    = "osdisk-${var.environment_name}-${var.location}-"        # Prefix for OS disk name
  gw_name_prefix                 = "gw-${var.environment_name}-${var.location}-"            # Prefix for gateway-related resources
}