locals {
  name = "${var.prefix}-db-${var.suffix}"
}

module "sql_database" {
  source              = "Azure/database/azurerm"
  resource_group_name = local.name
  location            = var.location
  db_name             = local.name
  sql_admin_username  = "mradministrator"
  sql_password        = "P@ssw0rd12345!"

  tags = var.tags

}