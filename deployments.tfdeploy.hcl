# Source environment secrets from HCP Terraform variable set
store "varset" "tokens" {
  id       = "varset-cge4cVYYF8PqvSCf"
  category = "env"
}

deployment "dev" {
    inputs = {
        client_id = store.varset.tokens.ARM_CLIENT_ID
        client_secret = store.varset.tokens.ARM_CLIENT_SECRET
        subscription_id = store.varset.tokens.ARM_SUBSCRIPTION_ID
        tenant_id = store.varset.tokens.ARM_TENANT_ID

        location = local.location
        prefix = "tfstack"
        suffix = "644547"
        cidr_range = "10.0.0.0/16"
        subnets = {
            subnet1 = ["10.0.0.0/24"]
        }
        tags = {
            environment = "dev"
        }
    }
}