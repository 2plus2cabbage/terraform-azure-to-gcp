# Defines GCP networking values for IPSEC connection
locals {
  gcp_vpn_ip       = var.gcp_vpn_ip       # The public IP of the GCP VPN Gateway
  gcp_subnet_cidr  = "10.2.1.0/24"        # The private network on the GCP side
}