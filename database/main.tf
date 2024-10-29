locals {
  name = "${var.prefix}-db-${var.suffix}"
}

resource "azurerm_resource_group" "main" {
  name     = local.name
  location = var.location
}

module "avm-res-sql-server" {
  source  = "Azure/avm-res-sql-server/azurerm"
  version = "0.1.1"

  name                         = local.name
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  administrator_login          = "mradministrator"
  administrator_login_password = "P@ssw0rd12345!"
  server_version               = "12.0"

  tags = var.tags
}