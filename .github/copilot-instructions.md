# Terraform Azure Template - GitHub Copilot Workspace Instructions

This repository is a **template for automated Azure Terraform IaC generation** using GitHub Copilot Workspace. When assigned to GitHub issues, Copilot should generate complete, production-ready Azure infrastructure following Well-Architected Framework principles.

## Repository Purpose & Workflow

**Template Repository Goal**: Enable rapid, automated generation of enterprise-grade Azure Terraform projects via GitHub Copilot Workspace.

**Expected Workflow**:
1. User clones this template repository
2. User creates GitHub issue describing their infrastructure requirements
3. User assigns GitHub Copilot agent to the issue
4. **Copilot generates complete project**: Terraform modules, environments, GitHub Actions, documentation
5. User deploys infrastructure immediately using generated CI/CD pipeline

**Copilot Agent Responsibilities**:
- Generate complete Terraform project structure based on issue requirements
- Create environment-specific configurations (dev/staging/prod)
- Generate GitHub Actions workflows for validation and deployment
- Apply Azure Well-Architected Framework principles across all 5 pillars
- Ensure security-first design with managed identities and private endpoints

## Key Patterns & Conventions

### Azure Well-Architected Framework Integration
- **Always implement all 5 pillars**: Security (managed identities, private endpoints), Reliability (multi-region, availability zones), Cost Optimization (tagging, right-sizing), Operational Excellence (IaC, monitoring), Performance Efficiency (auto-scaling, baselines)
- **Pattern Analysis First**: Before generating code, analyze the requested tasks to identify best practices and potential pitfalls and make research on Azure services as needed based on the links provided in the documentation section.

### Terraform Structure Conventions (from CLAUDE.md)
```
azure-infrastructure/
├── environments/           # Environment-specific configurations
│   ├── prod/dev/           # Separate folders per environment
├── modules/                # Reusable Terraform modules
│   ├── networking/app-service/sql-database/
├── backend.tf             # Azure Storage backend configuration
└── versions.tf            # Provider version pinning
```

### Security-First Approach
- **Default to managed identities** for all service-to-service authentication
- **Private endpoints mandatory** for all PaaS services unless explicitly justified
- **Azure Key Vault integration** for all secrets, certificates, connection strings
- **Network Security Groups** with restrictive rules by default

### Naming & Tagging Standards
- Follow **Microsoft Cloud Adoption Framework (CAF)** naming conventions
- Use **Azure naming module** for consistency: `module "naming" { source = "Azure/naming/azurerm" }`
- **Required tags**: Environment, Project, Owner, CostCenter, BusinessUnit, Criticality, DataClass, ManagedBy, LastModified

## Critical Development Workflows

### Terraform Validation Pipeline (Always Required)
```bash
terraform fmt -check=true              # Format validation
terraform validate                     # Syntax validation  
tflint --config=.tflint.hcl           # Azure-specific linting
checkov -f . --framework terraform    # Security scanning
terraform plan -out=tfplan            # Plan generation
```

### Provider Configuration Pattern
```hcl
terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
  backend "azurerm" { /* Azure Storage backend */ }
}

provider "azurerm" {
  features {
    key_vault { purge_soft_delete_on_destroy = true }
    resource_group { prevent_deletion_if_contains_resources = false }
  }
}
```

## Critical Anti-Patterns to Avoid

- **Never hardcode secrets** - Always use Key Vault references
- **Never skip global uniqueness** for storage accounts, web apps (use random suffix)  
- **Never use unpinned provider versions** - Always pin to specific versions
- **Never expose PaaS services publicly** - Use private endpoints by default
- **Never use local state** for team environments - Use Azure Storage backend
- **Never skip comprehensive tagging** - Required for governance and cost management

## Integration Points & Dependencies

### External Dependencies
- **Azure subscription** with appropriate RBAC permissions
- **Azure Storage Account** for Terraform state backend  
- **Azure Key Vault** for secrets management
- **Azure AD** for managed identities and RBAC

### Required Tools & Validation
- **TFLint** with Azure ruleset for best practices validation
- **Checkov** for security and compliance scanning
- **Azure CLI** for authentication and resource management

## GitHub Copilot Agent Instructions

When assigned to a GitHub issue requesting Azure infrastructure, follow this workflow:

### 1. Issue Analysis & Project Planning
- Parse the GitHub issue to understand infrastructure requirements
- Identify Azure services needed (App Service, AKS, databases, storage, etc.)
- Determine environment needs (dev/staging/prod configurations)
- Plan module structure based on services and dependencies

### 2. Generate Complete Project Structure
Create the full Terraform project following this structure:
```
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/
│   ├── compute/ (app-service, aks, vm)
│   ├── data/ (sql, cosmos, storage)
│   └── security/ (keyvault, nsg)
├── .github/workflows/
│   ├── terraform-validate.yml
│   ├── terraform-plan.yml
│   └── terraform-deploy.yml
├── backend.tf
├── versions.tf
├── locals.tf
└── README.md
```

### 3. Apply Azure Well-Architected Framework
Every generated resource must address the 5 pillars:
- **Security**: Managed identities, private endpoints, Key Vault integration
- **Reliability**: Multi-region, availability zones, backup strategies
- **Cost Optimization**: Appropriate SKUs, tagging strategy, auto-scaling
- **Operational Excellence**: Monitoring, alerting, Infrastructure as Code
- **Performance Efficiency**: Right-sized resources, performance baselines

### 4. Generate GitHub Actions Workflows
Create complete CI/CD pipelines with:
- **Validation workflow**: terraform fmt, validate, tflint, checkov
- **Planning workflow**: terraform plan on PR creation
- **Deployment workflow**: terraform apply with environment promotion
- **Security scanning**: Azure security best practices validation

### 5. Implementation Standards
- **Always use Azure Storage backend** for Terraform state
- **Pin provider versions** to avoid breaking changes
- **Follow CAF naming conventions** using Azure naming module
- **Implement comprehensive tagging** for governance and cost management
- **Default to private connectivity** with private endpoints
- **Include monitoring and alerting** for all critical resources

## Required GitHub Actions Templates

Generate these workflow files in `.github/workflows/`:

### terraform-validate.yml (PR Validation)
```yaml
name: Terraform Validate
on: [pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform fmt -check
      - run: terraform validate
      - run: tflint --config=.tflint.hcl
      - run: checkov -f . --framework terraform
```

### terraform-deploy.yml (Environment Deployment)
```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]
env:
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
```

## Deliverables Checklist

When completing an infrastructure request, ensure all items are generated:

**Core Infrastructure**:
- [ ] Complete Terraform modules for all requested Azure services
- [ ] Environment-specific configurations (dev/staging/prod)
- [ ] Backend configuration with Azure Storage
- [ ] Comprehensive variable definitions with validation

**Security & Governance**:
- [ ] Managed identities for all service-to-service authentication
- [ ] Private endpoints for all PaaS services
- [ ] Azure Key Vault integration for secrets management
- [ ] Comprehensive tagging strategy implementation

**CI/CD & Automation**:
- [ ] GitHub Actions workflows for validation and deployment
- [ ] Security scanning integration (Checkov, TFLint)
- [ ] Environment promotion workflows
- [ ] Deployment documentation and runbooks

**Monitoring & Operations**:
- [ ] Azure Monitor integration with alerting
- [ ] Log Analytics workspace configuration
- [ ] Application Insights for application monitoring
- [ ] Backup and disaster recovery procedures

## 📚 Azure Documentation and Resources

### Essential Azure References
- **Azure Well-Architected Framework**: https://learn.microsoft.com/en-us/azure/well-architected/
- **Azure Architecture Center**: https://learn.microsoft.com/en-us/azure/architecture/browse/
- **AzureRM Provider Documentation**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Azure Verified Modules**: https://azure.github.io/Azure-Verified-Modules/
- **Azure Naming Conventions**: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

### Azure Security and Governance
- **Azure Key Vault Best Practices**: https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices
- **Azure Private Endpoint Documentation**: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview
- **Azure RBAC Documentation**: https://learn.microsoft.com/en-us/azure/role-based-access-control/

### Terraform Azure Tools
- **TFLint Azure Rules**: https://github.com/terraform-linters/tflint-ruleset-azurerm
- **Checkov Azure Checks**: https://www.checkov.io/5.Policy%20Index/terraform.html
- **Azure Terraform Modules**: https://registry.terraform.io/browse/modules?provider=azurerm

**Final Goal**: User should be able to run `terraform apply` and deploy production-ready Azure infrastructure immediately after Copilot generates the project.