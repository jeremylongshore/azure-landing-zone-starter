locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
      purpose     = "portfolio-landing-zone-starter"
    },
    var.tags,
  )
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "./modules/network"

  name_prefix            = local.name_prefix
  location               = azurerm_resource_group.main.location
  resource_group_name    = azurerm_resource_group.main.name
  hub_address_space      = var.hub_address_space
  hub_app_subnet_prefix  = var.hub_app_subnet_prefix
  hub_data_subnet_prefix = var.hub_data_subnet_prefix
  spoke_address_space    = var.spoke_address_space
  spoke_subnet_prefix    = var.spoke_subnet_prefix
  tags                   = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  storage_account_id  = module.storage.storage_account_id
  log_retention_days  = var.log_retention_days
  alert_email         = var.alert_email
  tags                = local.common_tags
}
