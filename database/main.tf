locals {
  name = "${var.prefix}-db-${var.suffix}"
}

resource "azurerm_resource_group" "main" {
  name = local.name
    location = var.location

    tags = var.tags
}

module "sql_database" {
  source              = "Azure/database/azurerm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  db_name             = local.name
  sql_admin_username  = "mradministrator"
  sql_password        = "P@ssw0rd12345!"

  tags = var.tags

}