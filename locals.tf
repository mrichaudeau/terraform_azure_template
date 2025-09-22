locals {
  # Common tags applied to all resources
  common_tags = {
    Environment   = var.environment
    Project       = var.project_name
    Owner         = var.owner
    CostCenter    = var.cost_center
    BusinessUnit  = var.business_unit
    Criticality   = var.criticality
    DataClass     = var.data_classification
    ManagedBy     = "Terraform"
    LastModified  = timestamp()
  }

  # Naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Network configuration
  vnet_address_space = var.vnet_address_space
  subnets = {
    app     = cidrsubnet(local.vnet_address_space[0], 8, 1)  # 10.0.1.0/24
    data    = cidrsubnet(local.vnet_address_space[0], 8, 2)  # 10.0.2.0/24
    private = cidrsubnet(local.vnet_address_space[0], 8, 3)  # 10.0.3.0/24
  }
}