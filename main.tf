terraform {
  required_version = "~> 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "tfstate82633"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

########################
# Data Sources         #
########################

data "azurerm_client_config" "current" {}

########################
# Naming Module        #
########################

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
  prefix  = [var.project_prefix] # list(string) required
}

########################
# Core Resources       #
########################

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = module.naming.log_analytics_workspace.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#----------------------
# Key Vault with RBAC  
#----------------------
resource "azurerm_key_vault" "keyvault" {
  name                       = module.naming.key_vault.name_unique
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true # correct attribute name
}

resource "azurerm_role_assignment" "kv_secret_officer" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "secret" {
  name         = "secretname"
  value        = var.some_secret_value
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [azurerm_role_assignment.kv_secret_officer]
}

########################
# Azure Container Group#
########################

module "container_group" {
  source  = "Azure/avm-res-containerinstance-containergroup/azurerm"
  version = "0.1.0"

  name                = module.naming.container_group.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  restart_policy      = "Always"

  containers = {
    app = {
      image  = "${var.docker_registry_server}/${var.container_image}"
      cpu    = var.container_cpu
      memory = var.container_memory
      ports = [
        {
          port     = 80
          protocol = "TCP"
        }
      ]
      volumes = {
        tmp = {
          name       = "tmp"
          mount_path = "/tmp"
          empty_dir  = true
          read_only  = false
        }
      }
    }
  }

  diagnostics_log_analytics = {
    workspace_id  = azurerm_log_analytics_workspace.this.workspace_id
    workspace_key = azurerm_log_analytics_workspace.this.primary_shared_key
  }
}

############################################
# Deployment tracker (visible in Azure UI) #
############################################

resource "azurerm_resource_group_template_deployment" "deployment_tracker" {
  name                = "${var.project_prefix}-deployment-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"

  template_content = jsonencode({
    "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    resources      = []
  })

  depends_on = [
    azurerm_log_analytics_workspace.this,
    azurerm_key_vault.keyvault,
    module.container_group
  ]
}