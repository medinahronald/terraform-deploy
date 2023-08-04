variable "tfbackend_storage_account_name" {
  description = "Name of the Azure Storage Account where tfbackend will be placed"
  type        = string
}

variable "tfbackend_container_name" {
  description = "Name of the Azure Storage Container where tfbackend will be placed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "arm_client_id" {
  description = "Azure AD Application Client ID"
}

variable "arm_client_secret" {
  description = "Azure AD Application Client Secret"
}

variable "arm_subscription_id" {
  description = "Azure Subscription ID"
}

variable "arm_tenant_id" {
  description = "Azure AD Tenant ID"
}

variable "account_tier" {
  description = "Storage Account Tier"
}

variable "account_replication_type" {
  description = "Storage Account Replication Type"
}

variable "container_access_type" {
  description = "Storage Container Access Type"
}

variable "blob_type" {
  description = "Storage Blob Type"
}

variable "serviceplan_os_type" {
  description = "Azure App Service Plan OS Type"
}

variable "serviceplan_sku_name" {
  description = "Azure App Service Plan SKU Name"
}