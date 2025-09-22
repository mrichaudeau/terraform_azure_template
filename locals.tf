# Common locals used across all environments
locals {
  # Common tags applied to all resources
  common_tags = {
    Project      = var.project_name
    Environment  = var.environment_name
    Owner        = var.owner
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
    Criticality  = var.criticality
    DataClass    = var.data_class
    ManagedBy    = "Terraform"
    LastModified = formatdate("YYYY-MM-DD", timestamp())
  }

  # Environment-specific resource naming
  resource_suffix = var.environment_name

  # Network configuration
  vnet_address_space = var.vnet_address_space
  subnet_cidrs = {
    webapp      = cidrsubnet(local.vnet_address_space[0], 8, 1) # /24
    database    = cidrsubnet(local.vnet_address_space[0], 8, 2) # /24
    private_endpoints = cidrsubnet(local.vnet_address_space[0], 8, 3) # /24
  }

  # Security configuration
  allowed_ip_ranges = var.allowed_ip_ranges

  # Database configuration
  sql_admin_login = var.sql_admin_login
}