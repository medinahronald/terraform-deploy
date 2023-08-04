# WEBAPP DEPLOYMENT USING TERRAFORM

**1. Clone the repository**

**2. Configure Service Principal Name for Terraform**

Go to terraform.tfvars file and fill the correct SPN details into the following variables:

```bash
arm_client_id       = "xxxxxx-xxxx-xxxxxx-xxxxx"
arm_client_secret   = "xxxxxxxxxxxxxxxxxxxxxxxxx"
arm_subscription_id = "xxxxxx-xxxxxx-xxxxx-xx-xxxxxxx"
arm_tenant_id       = "xxxxx-xxxxx-xxxxxxxx"
```

**3. Terraform init**

**4. Terraform plan**

**5. Terraform apply**

### **In the list below you will find the resources that will be deployed using this Terraform configuration:**

- **Azure Provider Configuration:**
  - Configures authentication and subscription details using variables.

- **Terraform Backend Configuration:**
  - Configures Terraform backend storage using Azure Blob Storage.

- **Resource Group:**
  - Creates an Azure resource group.

- **Network Security Group (NSG):**
  - Creates a network security group and sets security rules to allow or deny traffic.

- **Virtual Network (VNet):**
  - Creates an Azure virtual network.

- **Subnets:**
  - Creates two subnets within the virtual network.

- **Subnet Network Security Group Association:**
  - Associates the previously created NSG with the subnets.

- **Storage Account:**
  - Creates an Azure storage account.

- **Storage Container:**
  - Creates a container within the storage account.

- **Storage Blob:**
  - Uploads an HTML file to the previously created container.

- **App Service Plan:**
  - Creates a service plan for the web app.

- **Web App:**
  - Creates a web app and configures it to run a Docker containerized application.

- **Webapp Private Endpoint:**
  - Creates a private endpoint for the web app.

- **Private DNS:**
  - Creates a private DNS zone.

- **Private DNS Zone Virtual Network Link:**
  - Links the private DNS zone to the virtual network.

- **Outputs:**
  - Defines an output to display the URL of the created web app.