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

component "vm" {
    source = "./vm"

    inputs = {
        location = var.location
        prefix = var.prefix
        suffix = var.suffix
        vm_subnet_id = component.network.subnet_ids[0]
        tags = var.tags
    }

    providers = {
        azurerm = provider.azurerm.this
    }
}

component "database" {
    source = "./database"

    inputs = {
        location = var.location
        prefix = var.prefix
        suffix = var.suffix
        tags = var.tags
    }

    providers = {
        azurerm = provider.azurerm.this
    }

    depends_on = [component.vm]
}