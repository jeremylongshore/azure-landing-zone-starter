provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # Required by azurerm 4.x. Prefer ARM_SUBSCRIPTION_ID env var in CI;
  # set explicitly via tfvars for local runs when needed.
  subscription_id = var.subscription_id
}
