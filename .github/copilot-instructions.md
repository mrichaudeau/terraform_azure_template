# Terraform Azure Template - Developer Instructions

Always follow these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

This repository is a **template for automated Azure Terraform IaC generation**. After cloning, use it as a foundation to generate complete, production-ready Azure infrastructure following Well-Architected Framework principles.

## Working Effectively

### Bootstrap the Development Environment
- Install all required tools in this exact order:
  - Install Terraform: `wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && sudo apt update && sudo apt install -y terraform` -- takes 3-5 minutes. NEVER CANCEL. Set timeout to 10+ minutes.
  - Install TFLint: `wget https://github.com/terraform-linters/tflint/releases/download/v0.53.0/tflint_linux_amd64.zip -O /tmp/tflint.zip && cd /tmp && unzip tflint.zip && sudo mv tflint /usr/local/bin/` -- takes 30 seconds.
  - Install Checkov: `pip3 install checkov --break-system-packages` -- takes 3-4 minutes. NEVER CANCEL. Set timeout to 10+ minutes.
  - Azure CLI is pre-installed in most environments. Verify with: `az --version`

### Build and Validate Terraform Code
- **ALWAYS run the complete validation pipeline** before committing changes:
  - `terraform fmt -check=true -recursive` -- validates formatting, takes <1 second
  - `terraform init` -- initializes backend and providers, takes 2-3 seconds
  - `terraform validate` -- validates syntax, takes <1 second  
  - `tflint --config=.tflint.hcl` -- runs linting rules, takes <1 second
  - `checkov -d . --framework terraform --quiet` -- security scanning, takes 1-2 seconds (WARNING: fails with network connectivity errors but continues)
  - `terraform plan` -- generates execution plan, takes 20-25 seconds (requires Azure authentication)

### Authentication Requirements
- **Azure CLI login required** for terraform plan/apply: Run `az login` first
- **Terraform planning fails without authentication** with error: "Please run 'az login' to setup account"
- **Provider configuration** must include `features {}` block or terraform plan fails
- Use `skip_provider_registration = true` for read-only operations (deprecated in v5.0)

### Timing and Timeouts
- **Tool Installation**: 10+ minutes total -- NEVER CANCEL these operations
- **Terraform operations**: Always complete quickly (<30 seconds) except `terraform plan` with Azure API calls
- **Validation pipeline**: Complete in under 5 seconds when run locally
- **TFLint Azure plugin installation**: FAILS due to GitHub API rate limits -- use basic rules only

## Validation Scenarios

### Always Test These Scenarios After Making Changes
- **Create a test Terraform module** with basic Azure resource (e.g., resource group)
- **Run complete validation pipeline** to ensure all tools work correctly
- **Test terraform init and validate** on the generated code
- **Verify terraform fmt** runs without errors on all .tf files
- **Ensure TFLint passes** with basic configuration (Azure plugin may not be available)

### Manual Validation Steps
- Create test infrastructure in structure: `environments/dev/`, `modules/resource-group/`
- Include proper `versions.tf` with provider configuration
- Test module referencing works correctly
- Verify tags and naming conventions are applied

## Common Tasks

### Repository Structure
```
.
├── .git/
├── .github/
│   └── copilot-instructions.md
└── README.md
```

### Required Project Structure (when generating infrastructure)
```
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── versions.tf
│   │   └── outputs.tf
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── data/
│   └── security/
├── .github/workflows/
│   ├── terraform-validate.yml
│   ├── terraform-plan.yml
│   └── terraform-deploy.yml
├── .tflint.hcl
├── backend.tf
├── versions.tf
├── locals.tf
└── README.md
```

### Essential TFLint Configuration (.tflint.hcl)
```hcl
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}
```

### Standard Provider Configuration
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true  # deprecated in v5.0
}
```

## Critical Workflows

### Always Follow Azure Well-Architected Framework
- **Security**: Managed identities, private endpoints, Key Vault integration
- **Reliability**: Multi-region, availability zones, backup strategies  
- **Cost Optimization**: Appropriate SKUs, tagging strategy, auto-scaling
- **Operational Excellence**: Monitoring, alerting, Infrastructure as Code
- **Performance Efficiency**: Right-sized resources, performance baselines

### Required Tags for All Resources
```hcl
tags = {
  Environment = "dev|staging|prod"
  Project     = "project-name"
  Owner       = "team-name"
  ManagedBy   = "terraform"
}
```

### Validation Commands That May Fail
- **TFLint Azure plugin**: `tflint --init` fails with GitHub API rate limits -- use basic rules only
- **Checkov online features**: Network connectivity issues cause warnings but do not stop execution
- **Terraform plan**: Requires `az login` authentication or will fail immediately

## Known Issues and Workarounds

### Tool Installation Issues
- **Terraform**: Standard apt installation works reliably
- **TFLint**: Use direct GitHub release download due to install script failures
- **Checkov**: Network warnings are normal and do not affect functionality

### Network Connectivity Limitations
- **TFLint Azure plugin**: Cannot install due to GitHub API access restrictions
- **Checkov API**: Prisma Cloud API access fails but local scanning works
- **Azure authentication**: Must use `az login` for any Azure API operations

### Git Operations
- Repository starts with only README.md and .github/copilot-instructions.md
- Use standard git commands for version control
- Generated infrastructure should be committed to version control
- Always check `git status` before committing to verify file scope

## Working with GitHub Copilot

### When Generating Azure Infrastructure
- **Always validate** generated code with the complete pipeline
- **Include provider configuration** in every environment
- **Follow naming conventions** using snake_case for resources
- **Apply security best practices** with private endpoints and managed identities
- **Test terraform init and validate** on generated modules before committing