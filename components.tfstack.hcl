component "network" {
    source = "./network"

    inputs = {
        location = var.location
        prefix = var.prefix
        suffix = var.suffix
        cidr_range = var.cidr_range
        subnets = var.subnets
        tags = var.tags
    }

    providers = {
        azurerm = provider.azurerm.this
    }
}