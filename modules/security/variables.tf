variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "data_subnet_id" {
  description = "ID of the data subnet for private endpoints"
  type        = string
}

variable "keyvault_private_dns_zone_id" {
  description = "ID of the Key Vault private DNS zone"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}