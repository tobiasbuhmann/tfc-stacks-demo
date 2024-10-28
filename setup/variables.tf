# The GitHub repo where we'll be creating secrets
variable "organization_name" {
  description = "The name of the organization in HCP Terraform"
  type        = string
}

variable "stacks" {
  description = "The workspaces to create a federated identity for."
  type = list(object({
    stack_name      = string
    deployment_name = string
    project_name    = string
    operations      = list(string)
  }))
}

variable "azure_subscription_id" {
  description = "The Azure subscription ID to grant Contributor role on."
  type        = string
}