# FastAPI Azure Infrastructure Template

This repository contains a complete, production-ready Terraform infrastructure template for deploying a **FastAPI application** with **Azure SQL Database** and **Cosmos DB** on Microsoft Azure. The infrastructure follows Azure Well-Architected Framework principles across all five pillars: Security, Reliability, Cost Optimization, Operational Excellence, and Performance Efficiency.

## 🏗️ Architecture Overview

The template deploys a secure, scalable FastAPI application with the following Azure services:

- **App Service**: Hosts the FastAPI application with managed identity and VNet integration
- **Azure SQL Database**: Relational database with private endpoint and automated backups
- **Cosmos DB**: NoSQL database with multi-region support and private endpoint
- **Key Vault**: Centralized secrets management with private endpoint
- **Virtual Network**: Private networking with subnets for different tiers
- **Application Insights**: Application monitoring and observability
- **Log Analytics**: Centralized logging and analytics

## 🛡️ Security Features

- **Private Endpoints**: All PaaS services use private endpoints for secure connectivity
- **Managed Identities**: App Service uses managed identity for secure authentication
- **Network Security Groups**: Restrictive rules limiting network access
- **Key Vault Integration**: All secrets stored and accessed via Azure Key Vault
- **Zero Trust Architecture**: No public database endpoints, VNet integration

## 📁 Repository Structure

```
├── environments/          # Environment-specific configurations
│   ├── dev/               # Development environment
│   ├── staging/           # Staging environment
│   └── prod/              # Production environment
├── modules/               # Reusable Terraform modules
│   ├── networking/        # VNet, subnets, NSGs, private DNS
│   ├── security/          # Key Vault, managed identities
│   ├── data/              # SQL Database, Cosmos DB
│   ├── compute/           # App Service, auto-scaling
│   └── monitoring/        # Application Insights, alerts
├── .github/workflows/     # CI/CD pipelines
├── backend.tf             # Remote state configuration
├── versions.tf            # Provider versions
└── locals.tf              # Common variables and tags
```

## 🚀 Quick Start

### Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Azure CLI** installed and configured
3. **Terraform** >= 1.5 installed
4. **Git** for cloning the repository

### 1. Clone and Setup

```bash
git clone <your-repository-url>
cd terraform_azure_template
```

### 2. Configure Backend Storage

Create an Azure Storage Account for Terraform state:

```bash
# Create resource group for Terraform state
az group create --name "rg-terraform-state-dev" --location "East US"

# Create storage account (replace <unique-suffix> with a unique value)
az storage account create \
  --resource-group "rg-terraform-state-dev" \
  --name "stterraformstatedev<unique-suffix>" \
  --sku "Standard_LRS" \
  --encryption-services blob

# Create container
az storage container create \
  --name "tfstate" \
  --account-name "stterraformstatedev<unique-suffix>"
```

### 3. Configure Variables

Update `environments/dev/terraform.tfvars` with your values:

```hcl
# Project Configuration
project_name = "your-fastapi-app"
location     = "East US"

# Azure AD Configuration
azuread_admin_login     = "admin@yourdomain.com"
azuread_admin_object_id = "your-azure-ad-object-id"

# Alert Configuration
alert_email_addresses = [
  "your-email@yourdomain.com"
]
```

### 4. Deploy Development Environment

```bash
cd environments/dev

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file=terraform.tfvars

# Apply configuration
terraform apply -var-file=terraform.tfvars
```

### 5. Access Your Application

After deployment, get the application URL:

```bash
terraform output app_service_url
```

## 🔧 Environment Configuration

### Development Environment
- **Location**: `environments/dev/`
- **Resources**: Basic SKUs for cost optimization
- **Networking**: `10.0.0.0/16` address space
- **Monitoring**: Basic alerting and 30-day log retention

### Staging Environment
- **Location**: `environments/staging/`
- **Resources**: Standard SKUs for performance testing
- **Networking**: `10.1.0.0/16` address space
- **Monitoring**: Enhanced alerting and 90-day log retention

### Production Environment
- **Location**: `environments/prod/`
- **Resources**: Premium SKUs with high availability
- **Networking**: `10.2.0.0/16` address space
- **Features**: Multi-region Cosmos DB, auto-scaling, 365-day log retention

## 🔐 Security Configuration

### Managed Identity Setup

The App Service uses a managed identity to access Azure services securely:

```hcl
# Managed identity is automatically created and assigned
# Access Key Vault secrets using identity
app_settings = {
  "SQL_CONNECTION_STRING" = "@Microsoft.KeyVault(VaultName=${key_vault_name};SecretName=sql-connection-string)"
  "COSMOS_CONNECTION_STRING" = "@Microsoft.KeyVault(VaultName=${key_vault_name};SecretName=cosmos-connection-string)"
}
```

### Network Security

- **VNet Integration**: App Service integrated with dedicated subnet
- **Private Endpoints**: SQL Database and Cosmos DB accessible only via private network
- **NSG Rules**: Restrictive network security group rules

## 📊 Monitoring and Alerting

### Application Insights

- **Performance Monitoring**: Automatic application performance monitoring
- **Availability Tests**: Synthetic monitoring of application endpoints
- **Custom Dashboards**: Pre-configured monitoring dashboards

### Alerts Configuration

The template includes alerts for:

- **CPU Usage**: Alert when > 70% (production) / 80% (staging) / 90% (dev)
- **Memory Usage**: Alert when > 70% (production) / 80% (staging) / 90% (dev)
- **Response Time**: Alert when > 3s (production) / 7s (staging) / 10s (dev)
- **Database DTU**: Alert when > 70% (production) / 85% (staging) / 90% (dev)

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

1. **Terraform Validate** (`terraform-validate.yml`)
   - Runs on pull requests
   - Format checking, validation, TFLint, Checkov security scanning
   - Multi-environment validation

2. **Terraform Plan** (`terraform-plan.yml`)
   - Generates Terraform plans for review
   - Cost estimation with Infracost
   - Plan artifacts uploaded for deployment

3. **Terraform Deploy** (`terraform-deploy.yml`)
   - Automated deployment to development
   - Manual approval required for staging/production
   - Post-deployment validation

### Required Secrets

Configure these secrets in your GitHub repository:

```
AZURE_CLIENT_ID          # Service Principal Client ID
AZURE_CLIENT_SECRET      # Service Principal Client Secret
AZURE_SUBSCRIPTION_ID    # Azure Subscription ID
AZURE_TENANT_ID          # Azure Tenant ID
AZURE_AD_ADMIN_OBJECT_ID # Azure AD Admin Object ID
INFRACOST_API_KEY        # Infracost API Key (optional)
```

## 🏷️ Tagging Strategy

All resources are tagged with:

```hcl
tags = {
  Environment   = "dev/staging/prod"
  Project       = "fastapi-app"
  Owner         = "Team Name"
  CostCenter    = "IT-Development/Platform/Production"
  BusinessUnit  = "Engineering"
  Criticality   = "Low/Medium/High"
  DataClass     = "Internal/Confidential"
  ManagedBy     = "Terraform"
  LastModified  = "timestamp"
}
```

## 🔧 FastAPI Application Configuration

Your FastAPI application should use the following environment variables:

```python
# Database connections (retrieved from Key Vault)
SQL_CONNECTION_STRING = os.getenv("SQL_CONNECTION_STRING")
COSMOS_CONNECTION_STRING = os.getenv("COSMOS_CONNECTION_STRING")
COSMOS_PRIMARY_KEY = os.getenv("COSMOS_PRIMARY_KEY")

# Database configuration
COSMOS_ENDPOINT = os.getenv("COSMOS_ENDPOINT")
COSMOS_DATABASE_NAME = os.getenv("COSMOS_DATABASE_NAME")
COSMOS_CONTAINER_NAME = os.getenv("COSMOS_CONTAINER_NAME")
SQL_DATABASE_NAME = os.getenv("SQL_DATABASE_NAME")

# Application Insights
APPINSIGHTS_INSTRUMENTATIONKEY = os.getenv("APPINSIGHTS_INSTRUMENTATIONKEY")
APPLICATIONINSIGHTS_CONNECTION_STRING = os.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING")

# Managed Identity
AZURE_CLIENT_ID = os.getenv("AZURE_CLIENT_ID")
```

### Health Check Endpoint

Implement a health check endpoint for monitoring:

```python
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0"
    }
```

## 📈 Cost Optimization

### Development Environment
- **App Service**: B1 Basic tier (~$13/month)
- **SQL Database**: S0 Standard tier (~$15/month)
- **Cosmos DB**: 400 RU/s manual scaling (~$24/month)
- **Estimated Monthly Cost**: ~$60-80

### Production Environment
- **App Service**: P1v3 Premium tier with auto-scaling (~$80-200/month)
- **SQL Database**: P2 Premium tier (~$465/month)
- **Cosmos DB**: Auto-scaling up to 10,000 RU/s (~$150-400/month)
- **Estimated Monthly Cost**: ~$700-1100

## 🛠️ Troubleshooting

### Common Issues

1. **Backend State Lock**
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **Key Vault Access Issues**
   - Verify managed identity has proper access policies
   - Check private endpoint connectivity

3. **Database Connection Issues**
   - Verify VNet integration is working
   - Check NSG rules and private endpoints

### Validation Commands

```bash
# Format validation
terraform fmt -check=true

# Configuration validation
terraform validate

# Security scanning
checkov -f . --framework terraform

# Azure-specific linting
tflint --config=.tflint.hcl
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the established patterns
4. Ensure all validation passes
5. Submit a pull request

## 📚 Additional Resources

- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/)
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure SQL Database Documentation](https://docs.microsoft.com/en-us/azure/azure-sql/)
- [Azure Cosmos DB Documentation](https://docs.microsoft.com/en-us/azure/cosmos-db/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

## 📄 License

This template is provided under the MIT License. See LICENSE file for details.

---

**Ready to deploy your FastAPI application to Azure? Get started with `terraform apply`!** 🚀