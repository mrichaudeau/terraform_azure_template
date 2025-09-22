# Backend configuration for Terraform state storage in Azure Storage
# This configuration will be used by azd to store Terraform state securely

# Configuration variables for backend (set via azd or terraform init)
# storage_account_name = "terraform state storage account name"
# container_name       = "terraform state container name"  
# key                  = "terraform state file key"
# resource_group_name  = "terraform state resource group"
# subscription_id      = "subscription id for state storage"
# tenant_id           = "tenant id for authentication"

# Example terraform init command:
# terraform init -backend-config="storage_account_name=<name>" -backend-config="container_name=terraform-state" -backend-config="key=python-sql-webapp.tfstate"