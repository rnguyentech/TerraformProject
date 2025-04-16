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

# Azure Client Config Data Source
data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
  prefix  = [var.project_prefix]
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.rg.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.rg.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_key_vault" "keyvault" {
  location                  = azurerm_resource_group.rg.location
  name                      = module.naming.key_vault.name_unique
  resource_group_name       = azurerm_resource_group.rg.name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
}

locals {
  secret_ttl = "${var.secret_ttl_hours}h"
}

resource "azurerm_key_vault_secret" "secret" {
  key_vault_id    = azurerm_key_vault.keyvault.id
  name            = "secretname"
  value           = "password123" #demo only
  expiration_date = timeadd(timestamp(), local.secret_ttl)
}

module "container_group" {
  source  = "Azure/avm-res-containerinstance-containergroup/azurerm"
  version = "0.1.0"

  location            = azurerm_resource_group.rg.location
  name                = module.naming.container_group.name_unique
  resource_group_name = azurerm_resource_group.rg.name

  os_type        = "Linux"
  restart_policy = "Always"

  diagnostics_log_analytics = {
    workspace_id  = azurerm_log_analytics_workspace.this.workspace_id
    workspace_key = azurerm_log_analytics_workspace.this.primary_shared_key
  }

  containers = {
    app = {
      image   = var.container_image
      cpu     = var.container_cpu
      memory  = var.container_memory
      ports   = [{ port = 80, protocol = "TCP" }]
      volumes = {}
    }
  }

  exposed_ports = [{ port = 80, protocol = "TCP" }]

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }
}
