# Detailed Cross-Cloud Deployment Guide: Azure-to-GCP Terraform Deployment

This guide provides a unified, step-by-step journey to deploy a Windows Server 2022 VM in Microsoft Azure and another in Google Cloud Platform (GCP), connecting them with an IPSEC VPN tunnel for cross-cloud communication. Follow the steps in order to set up both environments and establish connectivity.

## Prerequisites
Before starting, ensure you have the following for both clouds:

### For Azure
- An Azure account with a subscription.
- An App Registration with Contributor role, noting `subscription_id`, `client_id`, `client_secret`, `tenant_id`.
- Azure region (e.g., `eastus`).

### For GCP
- A GCP account with a project.
- GCP credentials: `project_id` and `credentials_file` (path to the service account key JSON file).
- GCP region (e.g., `us-central1`).

### General
- Terraform installed on your machine.
- Visual Studio Code (VSCode) or another editor for modifying files.
- Your public IP address for RDP access (e.g., `203.0.113.5/32`; find it using a service like `whatismyipaddress.com`).
- **Note**: Cloud providers regularly change their console interfaces without notice. Steps outlined today may not apply exactly tomorrow.

## Deployment Steps

### Step 1: Update `terraform.tfvars` for Azure
1. In the Azure project directory, open the `terraform.tfvars` file in your editor (e.g., VSCode).
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
2. To get the public IP of the Azure VM, run `terraform output azure_vm_public_ip` in the terminal. Note this IP (e.g., `54.123.45.67`) for RDP access later.
3. Alternatively, find the public IP in the Azure Portal:
   - Go to **Virtual Machines**.
   - Locate the instance named `vm-<environment_name>-<location>-windows-001` (e.g., `vm-cabbage-eastus-windows-001`).
   - Note the "Public IP address" in the details pane.

### Step 4: Update `terraform.tfvars` for GCP
1. In the GCP project directory, open the `terraform.tfvars` file in your editor (e.g., VSCode).
2. Update the following fields with your information:
   - `project_id`: Replace `"<your-project-id>"` with your GCP project ID (e.g., `my-gcp-project-123`).
   - `region`: Replace `"<your-region>"` with your GCP region (e.g., `us-central1`).
   - `credentials_file`: Replace `"<path-to-credentials-file>"` with the path to your GCP credentials JSON file (e.g., `/path/to/credentials.json`).
   - `environment_name`: Replace `"<your-environment-name>"` with your environment name (e.g., `cabbage`).
   - `location`: Replace `"<your-location>"` with your location identifier (e.g., `uscentral1`).
   - `my_public_ip`: Replace `"<your-public-ip>"` with your public IP (e.g., `203.0.113.5/32`).
   - `shared_secret_azure`: Replace `"<your-shared-secret>"` with the same shared secret used in the Azure project (e.g., `abc123...`).
   - `azure_vpn_ip`: Replace `"<azure-vpn-ip>"` with the `azure_vpn_ip` value from step 3 (e.g., `52.86.55.82`).
3. Save the file.

### Step 5: Initialize and Deploy the GCP Project
1. In the GCP project terminal, run `terraform init` to initialize the Terraform working directory and download providers. This should take about 30 seconds.
2. (Optional) Run `terraform plan` to preview the changes Terraform will make. Review the output to ensure it looks correct (should take 15-30 seconds).
3. Run `terraform apply` to deploy the GCP resources. Type `yes` when prompted to confirm. This will create the VPC, subnet, VM, and VPN resources (takes about 2-5 minutes).

### Step 6: Retrieve the GCP VM Public IP and VPN IP
1. After deployment, Terraform will output several values. Note the `gcp_vpn_ip` value (e.g., `35.196.116.13`) for use in the Azure project.
2. To get the public IP of the GCP VM, run `terraform output gcp_vm_public_ip` in the terminal. Note this IP (e.g., `34.123.45.67`) for RDP access.
3. Alternatively, find the public IP in the GCP Console:
   - Go to **Compute Engine > VM instances**.
   - Locate the instance named `vm-<environment_name>-<location>-windows-001` (e.g., `vm-cabbage-uscentral1-windows-001`).
   - Note the "External IP" in the details pane.

### Step 7: Connect to the GCP VM via RDP
1. Open your Remote Desktop client (e.g., Microsoft Remote Desktop).
2. Enter the public IP of the GCP VM from the `gcp_vm_public_ip` output (e.g., `34.123.45.67`).
3. Use the username and password retrieved in step 8.
4. Connect to the VM.

### Step 8: Update Azure Configuration with GCP VPN IP
1. In the Azure project directory, open the `terraform.tfvars` file in your editor.
2. Update the `gcp_vpn_ip` field with the `gcp_vpn_ip` value from step 6 (e.g., `35.196.116.13`).
3. Save the file.
4. In the Azure project terminal, run `terraform apply` to apply the updates. Type `yes` to confirm (takes about 2-5 minutes).

### Step 9: Verify the Tunnel in GCP
1. Go to the GCP Console: **VPC Network > Cloud VPN**.
2. Select the connection named `vpn-<environment_name>-<location>-to-azure`.
3. Confirm the tunnel status is "Established".

### Step 10: Verify the Tunnel in Azure
1. Go to the Azure Portal: **Virtual Network Gateways > Connections**.
2. Select the connection named `conn-<environment_name>-<location>-to-gcp`.
3. Confirm the status is "Connected".

### Step 11: Connect to the Azure VM via RDP
1. Open your Remote Desktop client (e.g., Microsoft Remote Desktop).
2. Enter the public IP of the Azure VM from the `azure_vm_public_ip` output (e.g., `54.123.45.67`).
3. Use the username defined in `locals.tf` (e.g., `adminuser`) and the password from `terraform.tfvars` (`windows_admin_password`).
4. Connect to the VM.

### Step 12: Verify Connectivity Between Azure and GCP VMs
1. From the Azure VM, open Command Prompt or PowerShell.
2. Ping the GCP VM’s private IP (e.g., `terraform output gcp_vm_private_ip` in the GCP project, such as `10.2.1.10`).
3. From the GCP VM, ping the Azure VM’s private IP (e.g., `terraform output azure_vm_private_ip` in the Azure project, such as `10.4.1.10`).
4. Confirm bidirectional connectivity is successful. If the ping from Azure to GCP fails, verify the Windows Firewall is disabled on the Azure VM by running `netsh advfirewall show allprofiles` in PowerShell (it should show `State: OFF`). If enabled, disable it with `netsh advfirewall set allprofiles state off` and check for system policies re-enabling it. Repeat the same check on the GCP VM.

### Step 13: Clean Up Resources
1. In the GCP project terminal, run `terraform destroy` to remove all GCP resources. Type `yes` to confirm (takes about 1-2 minutes).
2. In the Azure project terminal, run `terraform destroy` to remove all Azure resources. Type `yes` to confirm (takes about 1-2 minutes).

## Potential Costs and Licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.