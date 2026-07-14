resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Wire storage account metrics/logs into Log Analytics.
# Blob service path is the most useful free-tier diagnostic surface.
resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
  name                       = "diag-storage-blob"
  target_resource_id         = "${var.storage_account_id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}

resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-${var.name_prefix}-ops"
  resource_group_name = var.resource_group_name
  short_name          = "alzops"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.alert_email != "" ? [var.alert_email] : []
    content {
      name                    = "ops-email"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

# Fire when storage account Availability drops below 100% over a 5-minute window.
resource "azurerm_monitor_metric_alert" "storage_availability" {
  name                = "alert-${var.name_prefix}-storage-availability"
  resource_group_name = var.resource_group_name
  scopes              = [var.storage_account_id]
  description         = "Storage account Availability below 100%. See runbook.md."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  auto_mitigate       = true
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}
