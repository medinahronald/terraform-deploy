# Provider configuration (Azure)
provider "azurerm" {
  features {}
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
  subscription_id = var.arm_subscription_id
  tenant_id       = var.arm_tenant_id
}

# Terraform Backend
terraform {
  backend "azurerm" {
    resource_group_name   = var.resource_group_name
    storage_account_name  = var.tfbackend_storage_account_name
    container_name        = var.tfbackend_container_name
    key                   = "terraform.tfstate"
  }
}

# Resource Group
resource "azurerm_resource_group" "rsg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "dev"
  }
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg.name
}

# NSG Rules
resource "azurerm_network_security_rule" "deny_http" {
  name                        = "deny-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rsg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "allow-https"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rsg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg.name
}

# Subnets
resource "azurerm_subnet" "subnet" {
  name                = "subnet-webapp"
  resource_group_name = azurerm_resource_group.rsg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = ["10.0.1.0/24"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "subnet-extra" {
  name                = "subnet-extra"
  resource_group_name = azurerm_resource_group.rsg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = ["10.0.2.0/24"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet_network_security_group_association" "nsgassoc1" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsgassoc2" {
  subnet_id                 = azurerm_subnet.subnet-extra.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Storage Account
resource "azurerm_storage_account" "storage_account" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.rsg.name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  tags = {
    environment = "dev"
  }
}

# Storage Container
resource "azurerm_storage_container" "html_container" {
  name                  = "webapp"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.container_access_type
}

# Storage Blob
resource "azurerm_storage_blob" "html_blob" {
  name                   = "index.html"
  storage_account_name  = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.html_container.name
  type                   = var.blob_type
  source                 = "${path.module}/index.html"
}

# App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "my-app-service-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg.name
  os_type             = var.serviceplan_os_type
  sku_name            = var.serviceplan_sku_name

  tags = {
    environment = "dev"
  }
}

# Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = "my-web-app"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg.name
  service_plan_id = azurerm_service_plan.app_service_plan.id

  site_config {
    // TLS
    minimum_tls_version = "1.2"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "HTML_CONTENT_URL" = azurerm_storage_blob.html_blob.url
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
  }

  depends_on = [
    azurerm_storage_blob.html_blob,
    azurerm_service_plan.app_service_plan
  ]
}

# Webapp Private Endpoint

resource "azurerm_private_endpoint" "webapp_privateendpoint" {
  name                = "${azurerm_linux_web_app.web_app.name}-endpoint"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  subnet_id           = azurerm_subnet.subnet.id
  
  private_service_connection {
    name                           = "${azurerm_linux_web_app.web_app.name}-privateconnection"
    private_connection_resource_id = azurerm_linux_web_app.web_app.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}

# Private DNS
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rsg.name
}

# Private DNS Link
resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "${azurerm_linux_web_app.web_app.name}-dnslink"
  resource_group_name   = azurerm_resource_group.rsg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled = false
}

# Outputs
output "web_app_url" {
  value = azurerm_linux_web_app.web_app.default_hostname
}