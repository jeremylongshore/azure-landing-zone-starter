output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "hub_app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "hub_data_subnet_id" {
  value = azurerm_subnet.data.id
}

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  value = azurerm_virtual_network.spoke.name
}

output "spoke_subnet_id" {
  value = azurerm_subnet.spoke.id
}

output "app_nsg_id" {
  value = azurerm_network_security_group.app.id
}

output "data_nsg_id" {
  value = azurerm_network_security_group.data.id
}
