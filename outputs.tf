output "container_group_name" {
  value = module.container_group.container_group_name
}

output "fqdn" {
  value = module.container_group.fqdn
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}