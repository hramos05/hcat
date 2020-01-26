/*
  The terraform code will deploy the following Azure resources:
    1. Resource Group
    2. Azure App Service Plan
    3. Azure App Service (Web App supporting ASP.NET)

  Author : Heinz Ramos
  Github : https://github.com/hramos05/hcat/tree/production/Code-01
*/
# ------------------------------------------------------------
#  Variables
# ------------------------------------------------------------
variable "rg_name" {
  default     = "RG-Website"
  description = "Name of the resource group"
}
variable "rg_location" {
  default     = "East US 2"
  description = "Location of resource group"
}
variable "environment" {
  default = "demo"
}

locals {
  # Hash of Tags
  common_tags = {
    "Deployment Method" = "Terraform"
    "Code Author"       = "Heinz Ramos"
    "Environment"       = var.environment
  }
}

# ------------------------------------------------------------
#  Main Process
# ------------------------------------------------------------
# Azure Connection, assume connection is made using Azure CLI
provider "azurerm" {
  /* 
    Only required if Azure CLI authentication is having issues
    This will use an Azure Service Principal with contributor rights to the sbuscription

    subscription_id = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
    client_id       = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
    client_secret   = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
    tenant_id       = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
  */
}

# Create the Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_name}-${var.environment}"
  location = var.rg_location
  tags     = local.common_tags
}

# Create App Service Plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "ASP-Website-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  sku {
    tier = "Free"
    size = "F1"
  }
}

# Create a Random String
resource "random_string" "app_service" {
  length  = 4
  special = false
}

# Create App Service
resource "azurerm_app_service" "app_service" {
  name                = "AS-Website-${random_string.app_service.result}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = "true"
  tags                = local.common_tags
}

# ------------------------------------------------------------
#  Outputs
# ------------------------------------------------------------
output "website_url" {
  value = "https://${azurerm_app_service.app_service.default_site_hostname}"
}

output "website_xcredentials" {
  sensitive = true
  value     = azurerm_app_service.app_service.site_credential
}

