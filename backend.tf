# Backend configuration for Terraform state
# This should be configured per environment
terraform {
  backend "azurerm" {
    # Configuration will be provided via backend config files or CLI
    # Example:
    # resource_group_name  = "rg-terraform-state"
    # storage_account_name = "stterraformstate<unique_suffix>"
    # container_name       = "tfstate"
    # key                  = "fastapi-app.terraform.tfstate"
  }
}