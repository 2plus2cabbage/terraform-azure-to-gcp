<img align="right" width="150" src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/2plus2cabbage.png">

<img src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/azure-to-gcp.png" alt="azure-to-gcp" width="300" align="left">
<br clear="left">

# Azure Windows Instance Terraform Deployment

Deploys a Windows Server 2022 VM in Microsoft Azure with RDP, internet access, and an IPSEC VPN tunnel to a corresponding Windows VM in GCP for cross-cloud communication.

## Files
The project is split into multiple files to illustrate modularity and keep separate constructs distinct, making it easier to manage and understand.
- `main.tf`: Terraform provider block (`hashicorp/azurerm`).
- `azureprovider.tf`: Azure provider config with `subscription_id`, `client_id`, etc.
- `variables.tf`: Variables and locals for subscription, region, etc.
- `terraform.tfvars.template`: Template for sensitive/custom values; rename to `terraform.tfvars` and add your credentials.
- `locals.tf`: Local variables for naming conventions.
- `azure-networking.tf`: VNet, subnet, and networking CIDRs.
- `gcp-networking.tf`: GCP networking values (`gcp_vpn_ip`, `gcp_subnet_cidr`) for IPSEC.
- `securitygroup.tf`: Network security group for RDP (TCP 3389), ICMP, and outbound traffic.
- `routing-static.tf`: Route table for internet access and GCP subnet routing.
- `resourcegroup.tf`: Resource group.
- `ipsec-general.tf`: Shared IPSEC infrastructure (public IP, GatewaySubnet, Virtual Network Gateway).
- `ipsec-gcp.tf`: GCP-specific IPSEC resources (Local Network Gateway, VPN Connection).
- `windows.tf`: Windows VM, outputs public/private IPs.

## How It Works
- **Networking**: VNet and subnet provide connectivity. Route table enables inbound/outbound traffic and routes to GCP subnet via the IPSEC tunnel.
- **Security**: Allows RDP from your IP, ICMP from the GCP subnet, and all outbound traffic.
- **Instance**: Windows Server 2022 VM with public IP, firewall disabled via extension.
- **IPSEC Tunnel**: Establishes a VPN connection to a GCP project, allowing communication between the Azure and GCP Windows VMs.

## Prerequisites
- An Azure account with a subscription.
- An App Registration with Contributor role, noting `subscription_id`, `client_id`, `client_secret`, `tenant_id`.
- A corresponding GCP project with IPSEC support, providing the `gcp_vpn_ip` output.
- Terraform installed on your machine.
- Examples are demonstrated using Visual Studio Code (VSCode).

## Deployment Steps
1. Deploy the corresponding GCP project with IPSEC support to obtain the `gcp_vpn_ip` output.
2. Update `terraform.tfvars` with Azure credentials, admin username, admin password, your public IP in `my_public_ip`, and the shared secret in `shared_secret_gcp`.
3. Update `gcp-networking.tf` with the actual `gcp_vpn_ip` from the GCP project output.
4. Run `terraform init`, then (optionally) `terraform plan` to preview changes, then `terraform apply` (type `yes`).
5. Get the public IP from the `azure_vm_public_ip` output on the screen, or run `terraform output azure_vm_public_ip`, or check in the Azure Portal under **Virtual Machines**.
6. In the GCP project, update `azure-networking.tf` with the Azure VPN Gateway IP (`azure_vpn_ip` output) and run `terraform apply`.
7. Verify the tunnel in the Azure Portal under **Virtual Network Gateways > Connections** (should show "Connected").
8. From the Azure VM, ping the GCP VM’s private IP (`gcp_vm_private_ip` output) to confirm connectivity.
9. Use Remote Desktop to log in to the Azure VM with the username and password from `terraform.tfvars` (`admin_username` and `windows_admin_password`); change the password on first login.
10. To remove all resources, run `terraform destroy` (type `yes`).

## Potential costs and licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to fully understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.