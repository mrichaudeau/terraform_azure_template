# Variables for the networking module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = object({
    webapp            = string
    private_endpoints = string
  })
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for PaaS services"
  type        = bool
  default     = true
}

# Variables for private endpoint resources (passed from other modules)
variable "sql_server_id" {
  description = "ID of the SQL server for private endpoint"
  type        = string
  default     = ""
}

variable "sql_server_name" {
  description = "Name of the SQL server for private endpoint"
  type        = string
  default     = ""
}

variable "key_vault_id" {
  description = "ID of the Key Vault for private endpoint"
  type        = string
  default     = ""
}

variable "key_vault_name" {
  description = "Name of the Key Vault for private endpoint"
  type        = string
  default     = ""
}