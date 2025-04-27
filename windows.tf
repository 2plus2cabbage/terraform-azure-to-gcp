# Creates a public IP address for the Windows VM
resource "azurerm_public_ip" "cabbage_public_ip" {
  name                              = "${local.public_ip_prefix}001"                            # Name of the public IP
  location                          = var.location                                              # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                    # Resource group for the public IP
  allocation_method                 = "Static"                                                  # Static allocation for the public IP
  sku                               = "Standard"                                                # SKU for the public IP
}

# Creates a network interface for the Windows VM
resource "azurerm_network_interface" "cabbage_nic" {
  name                              = "${local.network_interface_prefix}001"                    # Name of the network interface
  location                          = var.location                                              # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                    # Resource group for the NIC
  ip_configuration {
    name                            = "${local.private_ip_prefix}001"                           # Name of the IP configuration
    subnet_id                       = azurerm_subnet.cabbage_subnet.id                          # Subnet for the NIC
    private_ip_address_allocation   = "Dynamic"                                                 # Dynamic private IP allocation
    public_ip_address_id            = azurerm_public_ip.cabbage_public_ip.id                    # Public IP for RDP access
  }
}

# Creates a Windows Server 2022 VM instance in Azure
resource "azurerm_windows_virtual_machine" "windows_instance" {
  name                              = "${local.windows_name_prefix}001"                         # Name of the Windows VM
  computer_name                     = "windows-001"                                             # Computer name for the VM
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                    # Resource group for the VM
  location                          = var.location                                              # Azure region for deployment
  size                              = "Standard_D2s_v3"                                         # VM size (compute resources)
  admin_username                    = local.admin_username                                      # Admin username for the VM
  admin_password                    = var.windows_admin_password                                # Admin password for the VM
  network_interface_ids             = [azurerm_network_interface.cabbage_nic.id]                # Network interface for the VM
  os_disk {
    name                            = "${local.diskos_name}001"                                 # Name of the OS disk
    caching                         = "ReadWrite"                                               # Disk caching type
    storage_account_type            = "Standard_LRS"                                            # Storage type for the OS disk
  }
  source_image_reference {
    publisher                       = "MicrosoftWindowsServer"                                  # Publisher of the Windows image
    offer                           = "WindowsServer"                                           # Offer for the Windows image
    sku                             = "2022-Datacenter"                                         # SKU for Windows Server 2022
    version                         = "latest"                                                  # Latest version of the image
  }
}

# Disables the Windows firewall on the VM
resource "azurerm_virtual_machine_extension" "disable_firewall" {
  name                              = "DisableFirewall"                                         # Name of the VM extension
  virtual_machine_id                = azurerm_windows_virtual_machine.windows_instance.id       # VM to apply the extension to
  publisher                         = "Microsoft.Compute"                                       # Publisher of the extension
  type                              = "CustomScriptExtension"                                   # Type of the extension
  type_handler_version              = "1.10"                                                    # Version of the extension handler
  auto_upgrade_minor_version        = true                                                      # Auto-upgrade minor versions
  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False; Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False > C:\\firewall_status.txt\""
    }
  SETTINGS
}

# Outputs the public IP of the Windows VM for RDP access
output "azure_vm_public_ip" {
  value                             = azurerm_public_ip.cabbage_public_ip.ip_address            # Public IP address of the VM
  description                       = "Public IP of the Azure Windows VM"                       # Description of the output
}

# Outputs the private IP of the Windows VM for internal networking
output "azure_vm_private_ip" {
  value                             = azurerm_network_interface.cabbage_nic.private_ip_address  # Private IP address of the VM
  description                       = "Private IP of the Azure Windows VM"                      # Description of the output
}