output "client_id" {
  value = module.tfc_oidc.azuread_application.client_id
}

output "subscription_id" {
  value = var.azure_subscription_id
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}