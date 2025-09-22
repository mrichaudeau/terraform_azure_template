# Deployment Guide - FastAPI Azure Infrastructure

This guide provides step-by-step instructions for deploying the FastAPI application infrastructure on Azure using Terraform.

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Azure Subscription** with Owner or Contributor role
- [ ] **Azure CLI** installed and logged in (`az login`)
- [ ] **Terraform** >= 1.5 installed
- [ ] **Git** for repository management
- [ ] **Visual Studio Code** (recommended) with Terraform extension

## 🔧 Pre-Deployment Setup

### 1. Azure Service Principal Setup

Create a service principal for Terraform automation:

```bash
# Create service principal
az ad sp create-for-rbac --name "terraform-fastapi-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/<your-subscription-id>"

# Output will include:
# - appId (AZURE_CLIENT_ID)
# - password (AZURE_CLIENT_SECRET)
# - tenant (AZURE_TENANT_ID)
```

### 2. Storage Account for Terraform State

```bash
# Set variables
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="stterraformstate$(openssl rand -hex 3)"
CONTAINER_NAME="tfstate"
LOCATION="East US"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location "$LOCATION"

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

# Create blob container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --account-key $ACCOUNT_KEY

echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Account Key: $ACCOUNT_KEY"
```

### 3. Environment Variables Setup

Create a `.env` file (don't commit to Git):

```bash
# Azure Authentication
export ARM_CLIENT_ID="<service-principal-app-id>"
export ARM_CLIENT_SECRET="<service-principal-password>"
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
export ARM_TENANT_ID="<your-tenant-id>"

# Terraform Backend Configuration
export TF_STATE_RESOURCE_GROUP="rg-terraform-state"
export TF_STATE_STORAGE_ACCOUNT="<storage-account-name>"
export TF_STATE_CONTAINER="tfstate"

# Additional Configuration
export TF_VAR_azuread_admin_object_id="<your-azure-ad-object-id>"
```

Load environment variables:
```bash
source .env
```

## 🚀 Development Environment Deployment

### Step 1: Clone and Configure

```bash
git clone <repository-url>
cd terraform_azure_template
```

### Step 2: Configure Development Variables

Edit `environments/dev/terraform.tfvars`:

```hcl
# Required Configuration
project_name = "my-fastapi-app"
location     = "East US"

# Your Information
owner         = "Development Team"
cost_center   = "IT-Development"
business_unit = "Engineering"

# Azure AD Configuration (Get from: az ad signed-in-user show)
azuread_admin_login     = "admin@yourdomain.com"
azuread_admin_object_id = "12345678-1234-1234-1234-123456789012"

# Alert Configuration
alert_email_addresses = [
  "dev-team@yourdomain.com"
]

# Development-specific settings
cors_allowed_origins = ["*"]  # Allow all for development
```

### Step 3: Initialize Terraform

```bash
cd environments/dev

# Create backend configuration
cat > backend.conf << EOF
resource_group_name  = "$TF_STATE_RESOURCE_GROUP"
storage_account_name = "$TF_STATE_STORAGE_ACCOUNT"
container_name       = "$TF_STATE_CONTAINER"
key                  = "dev/fastapi-app.terraform.tfstate"
EOF

# Initialize Terraform
terraform init -backend-config=backend.conf
```

### Step 4: Plan and Deploy

```bash
# Validate configuration
terraform validate

# Plan deployment
terraform plan -var-file=terraform.tfvars -out=tfplan

# Apply deployment
terraform apply tfplan
```

### Step 5: Verify Deployment

```bash
# Get outputs
terraform output app_service_url
terraform output key_vault_name
terraform output sql_server_fqdn

# Test application (if deployed)
APP_URL=$(terraform output -raw app_service_url)
curl -f "$APP_URL/health" || echo "Application not deployed yet"
```

## 🏗️ Staging Environment Deployment

### Step 1: Configure Staging

```bash
cd ../staging

# Update terraform.tfvars with staging-specific values
# Note: Use different IP ranges and resource naming
```

### Step 2: Deploy Staging

```bash
# Create backend configuration
cat > backend.conf << EOF
resource_group_name  = "$TF_STATE_RESOURCE_GROUP"
storage_account_name = "$TF_STATE_STORAGE_ACCOUNT"
container_name       = "$TF_STATE_CONTAINER"
key                  = "staging/fastapi-app.terraform.tfstate"
EOF

# Initialize and deploy
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

## 🎯 Production Environment Deployment

### Step 1: Production Checklist

- [ ] **Security Review**: Ensure all security requirements are met
- [ ] **Backup Strategy**: Verify backup configurations
- [ ] **Monitoring**: Configure production alerting
- [ ] **Custom Domain**: Set up custom domain and SSL certificate
- [ ] **Performance Testing**: Complete load testing on staging

### Step 2: Configure Production

```bash
cd ../prod

# Update terraform.tfvars with production values
```

Key production configurations:

```hcl
# Production-grade SKUs
app_service_sku    = "P1v3"
sql_database_sku   = "P2"

# Security settings
public_network_access_enabled = true  # Or false for private access only
cors_allowed_origins = [
  "https://yourdomain.com",
  "https://api.yourdomain.com"
]

# High availability
cosmos_secondary_region = "West US 2"
autoscale_min_instances = 2
autoscale_max_instances = 10

# Enhanced monitoring
cpu_alert_threshold = 70
memory_alert_threshold = 70
response_time_alert_threshold = 3
```

### Step 3: Deploy Production

```bash
# Production deployment requires manual approval
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars -out=tfplan

# Review plan carefully before applying
terraform apply tfplan
```

## 🏃‍♂️ FastAPI Application Deployment

### Application Structure

Create your FastAPI application with the following structure:

```
app/
├── main.py              # FastAPI application entry point
├── models/              # Database models
│   ├── sql_models.py    # SQLAlchemy models
│   └── cosmos_models.py # Cosmos DB document models
├── routers/             # API route definitions
│   ├── health.py        # Health check endpoint
│   ├── sql_routes.py    # SQL database operations
│   └── cosmos_routes.py # Cosmos DB operations
├── database/            # Database connection utilities
│   ├── sql_database.py  # SQL connection
│   └── cosmos_database.py # Cosmos DB connection
├── requirements.txt     # Python dependencies
└── startup.py          # Application startup script
```

### Sample FastAPI Application

`main.py`:
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
import logging
from routers import health, sql_routes, cosmos_routes

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="FastAPI Azure Demo",
    description="FastAPI application with SQL and Cosmos DB",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure based on environment
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router)
app.include_router(sql_routes.router, prefix="/api/sql")
app.include_router(cosmos_routes.router, prefix="/api/cosmos")

@app.on_event("startup")
async def startup_event():
    logger.info("FastAPI application starting up...")
    logger.info(f"Environment: {os.getenv('FASTAPI_ENV', 'unknown')}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

`routers/health.py`:
```python
from fastapi import APIRouter
from datetime import datetime
import os

router = APIRouter()

@router.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0",
        "environment": os.getenv("FASTAPI_ENV", "unknown")
    }
```

### Deployment Methods

#### Method 1: ZIP Deployment

```bash
# Create deployment package
zip -r app.zip app/ requirements.txt

# Deploy using Azure CLI
az webapp deployment source config-zip \
  --resource-group <resource-group-name> \
  --name <app-service-name> \
  --src app.zip
```

#### Method 2: GitHub Actions (Recommended)

Create `.github/workflows/deploy-app.yml`:

```yaml
name: Deploy FastAPI Application

on:
  push:
    branches: [main]
    paths: [app/**, requirements.txt]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ secrets.APP_SERVICE_NAME }}
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
          package: ./app
```

## 🔍 Post-Deployment Validation

### 1. Application Health Check

```bash
# Get application URL
APP_URL=$(terraform output -raw app_service_url)

# Test health endpoint
curl -f "$APP_URL/health"

# Expected response:
# {
#   "status": "healthy",
#   "timestamp": "2024-01-15T10:30:00.000Z",
#   "version": "1.0.0",
#   "environment": "dev"
# }
```

### 2. Database Connectivity

```bash
# Test SQL Database connection (from App Service)
curl -f "$APP_URL/api/sql/test-connection"

# Test Cosmos DB connection
curl -f "$APP_URL/api/cosmos/test-connection"
```

### 3. Security Validation

```bash
# Verify private endpoints
az network private-endpoint list \
  --resource-group <resource-group-name> \
  --query "[].{Name:name, State:privateLinkServiceConnections[0].privateLinkServiceConnectionState.status}"

# Check Key Vault access
az keyvault secret list --vault-name <key-vault-name>
```

### 4. Monitoring Setup

```bash
# View Application Insights
az monitor app-insights component show \
  --app <app-insights-name> \
  --resource-group <resource-group-name>

# Check alert rules
az monitor metrics alert list \
  --resource-group <resource-group-name>
```

## 🔄 Environment Management

### Promote Changes Across Environments

1. **Development → Staging**
   ```bash
   # Test in development
   cd environments/dev
   terraform apply
   
   # Promote to staging
   cd ../staging
   terraform plan
   terraform apply
   ```

2. **Staging → Production**
   ```bash
   # Validate staging
   cd environments/staging
   # Run integration tests
   
   # Deploy to production
   cd ../prod
   terraform plan
   # Manual approval required
   terraform apply
   ```

### Configuration Drift Detection

```bash
# Check for configuration drift
terraform plan -detailed-exitcode

# Exit codes:
# 0 = No changes
# 1 = Error
# 2 = Changes detected
```

## 🛠️ Troubleshooting Common Issues

### Issue 1: Terraform State Lock

```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>

# Prevention: Always use proper workspace management
```

### Issue 2: Key Vault Access Denied

```bash
# Check access policies
az keyvault show --name <key-vault-name> --query "properties.accessPolicies"

# Add access policy if needed
az keyvault set-policy --name <key-vault-name> \
  --object-id <managed-identity-object-id> \
  --secret-permissions get list
```

### Issue 3: Private Endpoint Connectivity

```bash
# Check private endpoint status
az network private-endpoint show \
  --name <private-endpoint-name> \
  --resource-group <resource-group-name> \
  --query "privateLinkServiceConnections[0].privateLinkServiceConnectionState"

# Verify DNS resolution
nslookup <sql-server-name>.database.windows.net
```

### Issue 4: Application Won't Start

```bash
# Check application logs
az webapp log tail --name <app-service-name> --resource-group <resource-group-name>

# Check app settings
az webapp config appsettings list \
  --name <app-service-name> \
  --resource-group <resource-group-name>
```

## 📊 Performance Optimization

### 1. App Service Optimization

```bash
# Enable Always On (production)
az webapp config set --name <app-service-name> \
  --resource-group <resource-group-name> \
  --always-on true

# Configure auto-scaling
az monitor autoscale create \
  --resource-group <resource-group-name> \
  --resource <app-service-plan-id> \
  --name <autoscale-name> \
  --min-count 2 --max-count 10 --count 2
```

### 2. Database Performance

```bash
# Monitor SQL Database DTU usage
az sql db show-usage --name <database-name> \
  --server <server-name> \
  --resource-group <resource-group-name>

# Monitor Cosmos DB metrics
az cosmosdb show --name <cosmosdb-account> \
  --resource-group <resource-group-name>
```

## 🔄 Backup and Recovery

### Automated Backups

- **SQL Database**: Automated backups enabled by default
- **Cosmos DB**: Automatic backups with configurable retention
- **App Service**: Optional app backup configuration

### Manual Backup

```bash
# Export SQL Database
az sql db export --server <server-name> \
  --name <database-name> \
  --admin-user <admin-user> \
  --admin-password <admin-password> \
  --storage-key <storage-key> \
  --storage-key-type StorageAccessKey \
  --storage-uri <storage-uri>

# Cosmos DB backup is automatic - configure retention period
```

## 🎯 Next Steps

1. **Custom Domain**: Configure custom domain and SSL certificate
2. **API Management**: Add Azure API Management for API gateway features
3. **Container Deployment**: Migrate to containerized deployment
4. **Multi-Region**: Expand to multiple Azure regions for high availability
5. **DevOps Integration**: Integrate with Azure DevOps for advanced CI/CD

## 📚 Additional Resources

- [Azure App Service Best Practices](https://docs.microsoft.com/en-us/azure/app-service/app-service-best-practices)
- [FastAPI Production Deployment](https://fastapi.tiangolo.com/deployment/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

**Need help?** Check the troubleshooting section or create an issue in the repository.