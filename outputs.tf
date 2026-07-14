output "resource_group_name" {
  description = "Resource group name."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "Resource group ID."
  value       = azurerm_resource_group.main.id
}

output "hub_vnet_id" {
  description = "Hub virtual network ID."
  value       = module.network.hub_vnet_id
}

output "hub_vnet_name" {
  description = "Hub virtual network name."
  value       = module.network.hub_vnet_name
}

output "hub_app_subnet_id" {
  description = "Hub app subnet ID."
  value       = module.network.hub_app_subnet_id
}

output "hub_data_subnet_id" {
  description = "Hub data subnet ID."
  value       = module.network.hub_data_subnet_id
}

output "spoke_vnet_id" {
  description = "Spoke (on-prem stand-in) virtual network ID."
  value       = module.network.spoke_vnet_id
}

output "storage_account_name" {
  description = "Storage account name."
  value       = module.storage.storage_account_name
}

output "storage_account_id" {
  description = "Storage account ID."
  value       = module.storage.storage_account_id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID."
  value       = module.monitoring.log_analytics_workspace_id
}

output "metric_alert_id" {
  description = "Storage availability metric alert ID."
  value       = module.monitoring.metric_alert_id
}
