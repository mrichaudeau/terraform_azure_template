variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.project_name))
    error_message = "Project name must be 2-20 characters long, contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = object({
    app     = string
    data    = string
    private = string
  })
  default = {
    app     = "10.0.1.0/24"
    data    = "10.0.2.0/24"
    private = "10.0.3.0/24"
  }
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}