locals {
  location = "eastus"
  project = "tfstack-testing"
}

identity_token "azurerm" {
  audience = ["api://AzureADTokenExchange"]
}

deployment "dev" {
    inputs = {
        identity_token = identity_token.azurerm.jwt
        client_id = "5d33fef5-156b-469d-9454-56fe7e8a2426"
        subscription_id = "4d8e572a-3214-40e9-a26f-8f71ecd24e0d"
        tenant_id = "f06624a8-558d-45ab-8a87-a88094a3995d"

        location = local.location
        prefix = "tfstack"
        suffix = "644547"
        cidr_range = "10.0.0.0/16"
        subnets = {
            subnet1 = ["10.0.0.0/24"]
        }
        tags = {
            environment = "dev"
            project = local.project
        }
    }
}