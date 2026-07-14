resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Storage account names: 3-24 lowercase alphanumeric, globally unique.
locals {
  # Strip non-alphanumeric from prefix, clamp, append random suffix.
  sa_base = substr(replace(lower(var.name_prefix), "/[^a-z0-9]/", ""), 0, 18)
  sa_name = "${local.sa_base}${random_string.suffix.result}"
}

resource "azurerm_storage_account" "main" {
  name                     = local.sa_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  shared_access_key_enabled       = true
  public_network_access_enabled   = true # private endpoints are out of free-tier scope

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "data" {
  name                  = "app-data"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# Lifecycle: cool after 30d, delete after 90d. Stand-in for backup retention policy.
resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "tier-and-expire"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["app-data/"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        delete_after_days_since_modification_greater_than          = 90
        tier_to_archive_after_days_since_modification_greater_than = 60
      }

      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }

      version {
        delete_after_days_since_creation = 30
      }
    }
  }
}
