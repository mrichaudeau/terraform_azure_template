# TFLint Configuration for Azure Terraform Best Practices

plugin "azurerm" {
  enabled = true
  version = "0.25.1"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Terraform Rules
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = true
}

# Azure-specific rules
rule "azurerm_cosmosdb_account_max_throughput" {
  enabled = true
}

rule "azurerm_mssql_database_max_size_gb" {
  enabled = true
}

rule "azurerm_app_service_plan_invalid_kind" {
  enabled = true
}

rule "azurerm_key_vault_purge_protection_enabled" {
  enabled = true
}