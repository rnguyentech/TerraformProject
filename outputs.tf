output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}

output "container_group_name" {
  value = module.container_group.container_group_name
}

output "key_vault_url" {
  value = azurerm_key_vault.keyvault.vault_uri
}
