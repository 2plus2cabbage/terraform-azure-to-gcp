# Defines variables for Azure project configuration
variable "subscription_id" {
  type        = string           # Azure subscription ID, found in Azure portal under Subscriptions
  description = "Azure subscription ID, found in Azure portal under Subscriptions"
}

variable "client_id" {
  type        = string           # Azure client ID, found in Azure portal under App Registrations
  description = "Azure client ID, found in Azure portal under App Registrations"
}

variable "client_secret" {
  type        = string           # Azure client secret, generated in Azure portal under App Registrations
  description = "Azure client secret, generated in Azure portal under App Registrations"
}

variable "tenant_id" {
  type        = string           # Azure tenant ID, found in Azure portal under Azure Active Directory
  description = "Azure tenant ID, found in Azure portal under Azure Active Directory"
}

variable "environment_name" {
  type        = string           # Name for your environment, used in resource naming
  description = "Name for your environment, used in resource naming"
}

variable "location" {
  type        = string           # Location identifier, used in resource naming
  description = "Location identifier, used in resource naming"
}

variable "my_public_ip" {
  type        = string           # Your public IP for RDP access
  description = "Your public IP for RDP access"
}

variable "windows_admin_password" {
  type        = string           # Password for the Windows VM admin user
  description = "Password for the Windows VM admin user"
}

variable "shared_secret_gcp" {
  type        = string           # Shared secret for Azure-to-GCP IPSEC tunnel
  description = "Shared secret for Azure-to-GCP IPSEC tunnel"
  sensitive   = true
}

variable "gcp_vpn_ip" {
  type        = string           # The public IP of the GCP VPN Gateway
  description = "The public IP of the GCP VPN Gateway"
}