output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}

output "action_group_id" {
  value = azurerm_monitor_action_group.ops.id
}

output "metric_alert_id" {
  value = azurerm_monitor_metric_alert.storage_availability.id
}
