# Detailed Deployment Guide: Azure-to-GCP Cross-Cloud Terraform Deployment

This guide provides step-by-step instructions to deploy a Windows Server 2022 VM in Microsoft Azure with RDP, internet access, and an IPSEC VPN tunnel to a corresponding Windows VM in GCP for cross-cloud communication.

## Prerequisites
Before starting, ensure you have the following:
- An Azure account with a subscription.
- An App Registration with Contributor role, noting `subscription_id`, `client_id`, `client_secret`, `tenant_id`.
- A corresponding GCP project with IPSEC support, providing the `gcp_vpn_ip` output.
- Terraform installed on your machine.
- Visual Studio Code (VSCode) or another editor for modifying files.
- Your public IP address for RDP access (e.g., `203.0.113.5/32`; find it using a service like `whatismyipaddress.com`).
- **Note**: Cloud providers regularly change their console interfaces without notice. Steps outlined today may not apply exactly tomorrow.

## Deployment Steps

### Step 1: Update `terraform.tfvars` with Azure Credentials and Configuration
1. Open the `terraform.tfvars` file in your editor (e.g., VSCode).
2. Update the following fields with your information:
   - `subscription_id`: Replace `"<your-subscription-id>"` with your Azure subscription ID (e.g., `12345678-1234-1234-1234-1234567890ab`).
   - `client_id`: Replace `"<your-client-id>"` with your Azure client ID (e.g., `87654321-4321-4321-4321-0987654321ba`).
   - `client_secret`: Replace `"<your-client-secret>"` with your Azure client secret (e.g., `your-secret-value`).
   - `tenant_id`: Replace `"<your-tenant-id>"` with your Azure tenant ID (e.g., `abcdef12-3456-7890-abcd-ef1234567890`).
   - `environment_name`: Replace `"<your-environment-name>"` with your environment name (e.g., `cabbage`).
   - `location`: Replace `"<your-location>"` with your Azure region (e.g., `eastus`).
   - `my_public_ip`: Replace `"<your-public-ip>"` with your public IP (e.g., `203.0.113.5/32`).
   - `windows_admin_password`: Replace `"<your-admin-password>"` with your admin password (e.g., `P@ssw0rd1234!`).
   - `shared_secret_gcp`: Replace `"<your-shared-secret>"` with the shared secret for the IPSEC tunnel (e.g., `abc123...`).
   - `gcp_vpn_ip`: Replace `"<gcp-vpn-ip>"` with the GCP VPN Gateway IP (e.g., `35.196.116.13` if available from a prior GCP deployment; otherwise, use a placeholder and update later).
3. Save the file.

### Step 2: Initialize and Deploy the Azure Project
1. Open a terminal in the Azure project directory.
2. Run `terraform init` to initialize the Terraform working directory and download providers. This should take about 30 seconds.
3. (Optional) Run `terraform plan` to preview the changes Terraform will make. Review the output to ensure it looks correct (should take 15-30 seconds).
4. Run `terraform apply` to deploy the Azure resources. Type `yes` when prompted to confirm. This will create the VNet, subnet, VM, and VPN resources (takes about 2-5 minutes).

### Step 3: Retrieve the Azure VM Public IP and VPN IP
1. After deployment, Terraform will output several values. Note the `azure_vpn_ip` value (e.g., `52.86.55.82`) for use in the GCP project.
2. To get the public IP of the Azure VM, run `terraform output azure_vm_public_ip` in the terminal. Note this IP (e.g., `54.123.45.67`) for RDP access.
3. Alternatively, find the public IP in the Azure Portal:
   - Go to **Virtual Machines**.
   - Locate the instance named `vm-<environment_name>-<location>-windows-001` (e.g., `vm-cabbage-eastus-windows-001`).
   - Note the "Public IP address" in the details pane.

### Step 4: Deploy the GCP Project with the Azure VPN IP
1. In the GCP project directory, open the `terraform.tfvars` file in your editor.
2. Update the `azure_vpn_ip` field with the `azure_vpn_ip` value from step 3 (e.g., `52.86.55.82`).
3. Save the file.
4. In the GCP project terminal, run `terraform init` to initialize Terraform (if not already done).
5. (Optional) Run `terraform plan` to preview changes.
6. Run `terraform apply` to deploy the GCP project. Type `yes` to confirm (takes about 2-5 minutes).
7. After deployment, note the `gcp_vpn_ip` output (e.g., `35.196.116.13`) for use in the next steps.

### Step 5: Update Azure Configuration with GCP VPN IP
1. In the Azure project directory, open the `terraform.tfvars` file in your editor.
2. Update the `gcp_vpn_ip` field with the `gcp_vpn_ip` value from step 4 (e.g., `35.196.116.13`).
3. Save the file.
4. In the terminal, run `terraform apply` to apply the updates. Type `yes` to confirm (takes about 2-5 minutes).

### Step 6: Verify the Tunnel
1. Go to the Azure Portal: **Virtual Network Gateways > Connections**.
2. Select the connection named `conn-<environment_name>-<location>-to-gcp`.
3. Confirm the status is "Connected".

### Step 7: Connect to the Azure VM via RDP
1. Open your Remote Desktop client (e.g., Microsoft Remote Desktop).
2. Enter the public IP of the Azure VM from the `azure_vm_public_ip` output (e.g., `54.123.45.67`).
3. Use the username defined in `locals.tf` (e.g., `adminuser`) and the password from `terraform.tfvars` (`windows_admin_password`).
4. Connect to the VM.

### Step 8: Verify Connectivity Between Azure and GCP VMs
1. From the Azure VM, open Command Prompt or PowerShell.
2. Ping the GCP VM’s private IP (e.g., `terraform output gcp_vm_private_ip` in the GCP project, such as `10.2.1.10`).
3. In the GCP project, connect to the GCP VM via RDP using the public IP from the `gcp_vm_public_ip` output.
4. From the GCP VM, ping the Azure VM’s private IP (e.g., `terraform output azure_vm_private_ip` in the Azure project, such as `10.4.1.10`).
5. Confirm bidirectional connectivity is successful. If the ping from Azure to GCP fails, verify the Windows Firewall is disabled on the Azure VM by running `netsh advfirewall show allprofiles` in PowerShell (it should show `State: OFF`). If enabled, disable it with `netsh advfirewall set allprofiles state off` and check for system policies re-enabling it. Repeat the same check on the GCP VM.

### Step 9: Clean Up Resources
1. In the terminal, run `terraform destroy` to remove all resources. Type `yes` to confirm (takes about 1-2 minutes).
2. Repeat this step in the GCP project to clean up its resources.

## Potential Costs and Licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.