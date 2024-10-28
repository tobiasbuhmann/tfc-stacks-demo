# Create randmo integer for OIDC name
resource "random_integer" "oidc" {
  min = 10000
  max = 99999
}

# Create Service Principals
data "azuread_client_config" "current" {}

locals {
  az_name = "stacks${random_integer.oidc.result}"
}

module "tfc_oidc" {
  source  = "ned1313/tfc_oidc/azuread"
  version = "0.2.0"

  identity_name     = local.az_name
  organization_name = var.organization_name
  stacks            = var.stacks

}

# Grant contributor role in current Azure subscription
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

data "azurerm_subscription" "main" {
  subscription_id = var.azure_subscription_id
}

resource "azurerm_role_assignment" "oidc" {
  scope                = data.azurerm_subscription.main.id
  role_definition_name = "Contributor"
  principal_id         = module.tfc_oidc.service_principal.object_id
}