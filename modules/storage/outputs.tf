output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "container_name" {
  value = azurerm_storage_container.data.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.main.primary_blob_endpoint
}
