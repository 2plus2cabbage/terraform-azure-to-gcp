<img align="right" width="150" src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/2plus2cabbage.png">

<img src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/azure-to-gcp.png" alt="azure-to-gcp" width="300" align="left">
<br clear="left">

# Azure-to-GCP Cross-Cloud Terraform Deployment

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
- **Note**: Cloud providers regularly change their console interfaces without notice. Steps outlined today may not apply exactly tomorrow.

## Procedural Note
Either the Azure or GCP project can be deployed first to obtain the first VPN IP; this example starts with Azure. The deployment must follow a specific order due to dependencies on VPN Gateway IPs:
- First, deploy this Azure project to obtain the `azure_vpn_ip` output in step 2.
- Then, in the GCP project, update `terraform.tfvars` with the `azure_vpn_ip`, deploy the GCP project, and note the `gcp_vpn_ip` output in step 4.
- Finally, update `terraform.tfvars` in this Azure project with the `gcp_vpn_ip`, and redeploy this project in step 5 to complete the tunnel setup.
Ensure the shared secret (`shared_secret_gcp` in Azure, `shared_secret_azure` in GCP) matches in both projects' `terraform.tfvars`.

## Deployment Steps
1. Update `terraform.tfvars` with Azure credentials, admin password in `windows_admin_password`, your public IP in `my_public_ip`, the shared secret in `shared_secret_gcp`, and the GCP VPN IP in `gcp_vpn_ip` (if available from a prior GCP deployment; otherwise, use a placeholder and update later).
2. Run `terraform init`, then (optionally) `terraform plan` to preview changes, then `terraform apply` (type `yes`).
3. Get the public IP from the `azure_vm_public_ip` output on the screen, or run `terraform output azure_vm_public_ip`, or check in the Azure Portal under **Virtual Machines**. Note the `azure_vpn_ip` output for use in the GCP project.
4. In the GCP project, update `terraform.tfvars` with the Azure VPN Gateway IP (`azure_vpn_ip` output) in `azure_vpn_ip`, deploy the GCP project with `terraform apply`, and note the `gcp_vpn_ip` output.
5. In this Azure project, update `terraform.tfvars` with the `gcp_vpn_ip` output in `gcp_vpn_ip`, and run `terraform apply`.
6. Verify the tunnel in the Azure Portal under **Virtual Network Gateways > Connections** (should show "Connected").
7. Use Remote Desktop to log in to the Azure VM with the username defined in `locals.tf` (e.g., `adminuser`) and the password from `terraform.tfvars` (`windows_admin_password`), using the public IP from the `azure_vm_public_ip` output.
8. From the Azure VM, ping the GCP VM’s private IP (`gcp_vm_private_ip` output) to confirm connectivity; then from the GCP VM, ping the Azure VM’s private IP (`azure_vm_private_ip` output) to confirm bidirectional connectivity. If the ping from Azure to GCP fails, verify the Windows Firewall is disabled on the Azure VM by running `netsh advfirewall show allprofiles` in PowerShell (it should show `State: OFF`). If enabled, disable it with `netsh advfirewall set allprofiles state off` and check for system policies re-enabling it.
9. To remove all resources, run `terraform destroy` (type `yes`).

## Potential costs and licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to fully understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.