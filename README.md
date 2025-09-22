# 🚀 Azure Python Web App with SQL Database

A production-ready Python Flask web application deployed to Azure App Service with SQL Database connectivity, implementing Azure Well-Architected Framework principles and enterprise security best practices.

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Deployment Guide](#-deployment-guide)
- [Configuration](#-configuration)
- [API Documentation](#-api-documentation)
- [Security](#-security)
- [Monitoring](#-monitoring)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## 🏗️ Architecture Overview

This solution implements a secure, scalable web application following Azure Well-Architected Framework principles:

### Architecture Diagram
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub        │    │   Azure DevOps  │    │   Local Dev     │
│   Actions       │───▶│   (Optional)     │───▶│   Environment   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Azure Resource Group                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   App Service   │  │   SQL Database  │  │   Key Vault     │ │
│  │   (Python App)  │──│   (Private EP)  │  │   (Secrets)     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│           │                       │                       │     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Application     │  │ Virtual Network │  │ Log Analytics   │ │
│  │ Insights        │  │ (Private Links) │  │ Workspace       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Components

- **Azure App Service**: Hosts the Python Flask application with managed identity
- **Azure SQL Database**: Secure database with private endpoint connectivity  
- **Azure Key Vault**: Manages secrets, connection strings, and certificates
- **Azure Virtual Network**: Provides private connectivity between services
- **Application Insights**: Monitors application performance and diagnostics
- **Log Analytics**: Centralized logging and monitoring
- **Private Endpoints**: Ensures secure, private connectivity to PaaS services

## ✨ Features

### 🛡️ Security Features
- **Zero Trust Architecture**: Private endpoints for all PaaS services
- **Managed Identity**: No hardcoded connection strings or passwords
- **Azure AD Integration**: Database authentication via managed identity
- **Key Vault Integration**: Secure secret management
- **HTTPS Only**: All communication encrypted in transit
- **Network Isolation**: VNet integration and private endpoints

### 🔧 Operational Features  
- **Infrastructure as Code**: Complete Terraform deployment
- **Multi-Environment**: Dev, Staging, Production configurations
- **CI/CD Pipeline**: GitHub Actions for automated deployment
- **Health Monitoring**: Built-in health checks and monitoring
- **Auto-scaling**: Automatic scaling based on demand
- **Backup & Recovery**: Automated database backups

### 📊 Application Features
- **RESTful API**: Full CRUD operations for user management
- **Database Integration**: Azure SQL with connection pooling
- **Error Handling**: Comprehensive error handling and logging
- **Metrics Collection**: Custom application metrics
- **Web Interface**: Responsive HTML interface
- **API Documentation**: Built-in API endpoints

## 🔧 Prerequisites

Before deploying this solution, ensure you have:

### Required Tools
- **Azure CLI** (v2.50.0+): `winget install Microsoft.AzureCLI`
- **Terraform** (v1.0+): `winget install Hashicorp.Terraform`
- **Azure Developer CLI** (azd): `winget install Microsoft.Azd`
- **Git**: `winget install Git.Git`
- **PowerShell** 7+: `winget install Microsoft.PowerShell`

### Azure Requirements
- **Azure Subscription** with Owner or Contributor access
- **Azure AD Permissions** to create service principals
- **Resource Quotas**: Ensure sufficient quota for App Service, SQL Database
- **Regional Availability**: All services available in target region

### Development Tools (Optional)
- **VS Code**: `winget install Microsoft.VisualStudioCode`
- **Python 3.11+**: `winget install Python.Python.3.11`
- **Docker Desktop**: `winget install Docker.DockerDesktop`

## 🚀 Quick Start

### 1. Clone and Setup
```powershell
# Clone the repository
git clone <repository-url>
cd terraform_azure_template

# Login to Azure
az login

# Set subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Initialize Azure Developer CLI
azd init --template .
```

### 2. Configure Environment
```powershell
# Copy and customize environment file
cp .env.example .env.local

# Edit configuration (use your preferred editor)
code .env.local
```

### 3. Deploy Infrastructure
```powershell
# Deploy to development environment
azd up --environment dev

# Or use Terraform directly
cd environments/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Deploy Application
```powershell
# Deploy the Python application
azd deploy --service web
```

## 📚 Deployment Guide

### Environment Configuration

The solution supports three environments with different configurations:

| Environment | SKU/Size | Features | Use Case |
|-------------|----------|----------|----------|
| **Development** | Basic B1 | Single instance, basic monitoring | Development & testing |
| **Staging** | Standard S1 | Auto-scaling, enhanced monitoring | Pre-production validation |
| **Production** | Premium P1v2 | High availability, advanced security | Production workloads |

### Step-by-Step Deployment

#### 1. Infrastructure Deployment

```powershell
# Navigate to desired environment
cd environments/prod  # or dev/staging

# Initialize Terraform
terraform init

# Create deployment plan
terraform plan -var-file="terraform.tfvars" -out=tfplan

# Review and apply changes
terraform apply tfplan
```

#### 2. Application Deployment

**Option A: Using Azure Developer CLI (Recommended)**
```powershell
# Deploy application with azd
azd deploy --service web --environment prod
```

**Option B: Using GitHub Actions**
1. Push code to main branch
2. GitHub Actions will automatically deploy to environments
3. Production deployments require manual approval

**Option C: Manual Deployment**
```powershell
# Build and deploy using Azure CLI
az webapp deployment source config-zip \
  --resource-group rg-python-sql-prod \
  --name app-python-sql-prod \
  --src src.zip
```

#### 3. Database Setup

```powershell
# Connect to SQL Database using Azure CLI
sqlcmd -S your-server.database.windows.net -d python-sql-db -G

# Create application tables
sqlcmd -i sql/init-database.sql
```

### Post-Deployment Configuration

#### 1. Configure Managed Identity
```powershell
# Grant managed identity access to SQL Database
az sql server ad-admin set \
  --resource-group rg-python-sql-prod \
  --server-name sql-python-sql-prod \
  --display-name "App Service Managed Identity" \
  --object-id $(az webapp identity show --name app-python-sql-prod --resource-group rg-python-sql-prod --query principalId -o tsv)
```

#### 2. Verify Connectivity
```powershell
# Test application health
curl https://app-python-sql-prod.azurewebsites.net/health

# Test API endpoints
curl https://app-python-sql-prod.azurewebsites.net/api/users
```

## ⚙️ Configuration

### Environment Variables

The application uses the following configuration:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `AZURE_SQL_SERVER` | SQL Server FQDN | From Key Vault | ✅ |
| `AZURE_SQL_DATABASE` | Database name | From Key Vault | ✅ |
| `AZURE_CLIENT_ID` | Managed Identity ID | Auto-configured | ✅ |
| `KEY_VAULT_URL` | Key Vault endpoint | Auto-configured | ✅ |
| `APPLICATION_INSIGHTS_CONNECTION_STRING` | App Insights | Auto-configured | ✅ |
| `ENVIRONMENT` | Deployment environment | dev/staging/prod | ✅ |
| `LOG_LEVEL` | Logging verbosity | INFO | ❌ |

### Terraform Variables

Key Terraform variables for customization:

```hcl
# Core Configuration
variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "python-sql"
}

# App Service Configuration
variable "app_service_sku" {
  description = "App Service SKU"
  type        = string
  default     = "B1"
}

# SQL Database Configuration  
variable "sql_sku" {
  description = "SQL Database SKU"
  type        = string
  default     = "Basic"
}
```

## 📡 API Documentation

### Base URL
- **Development**: `https://app-python-sql-dev.azurewebsites.net`
- **Staging**: `https://app-python-sql-staging.azurewebsites.net`  
- **Production**: `https://app-python-sql-prod.azurewebsites.net`

### Endpoints

#### Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "database": "connected",
  "version": "1.0.0"
}
```

#### User Management

**Get All Users**
```http
GET /api/users
```

**Create User**
```http
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}
```

**Get User by ID**
```http
GET /api/users/{id}
```

**Update User**
```http
PUT /api/users/{id}
Content-Type: application/json

{
  "name": "Jane Doe",
  "email": "jane@example.com"
}
```

**Delete User**
```http
DELETE /api/users/{id}
```

#### Metrics

**Log Application Metric**
```http
POST /api/metrics
Content-Type: application/json

{
  "metric_name": "page_view",
  "value": 1.0,
  "tags": {
    "page": "home",
    "user_agent": "Mozilla/5.0..."
  }
}
```

### Error Responses

All endpoints return consistent error responses:

```json
{
  "error": "Resource not found",
  "error_code": "USER_NOT_FOUND",
  "request_id": "123e4567-e89b-12d3-a456-426614174000",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 🔒 Security

### Security Implementation

#### 1. Authentication & Authorization
- **Managed Identity**: App Service uses system-assigned managed identity
- **Azure AD Integration**: SQL Database authentication via Azure AD
- **RBAC**: Role-based access control for all Azure resources
- **Key Vault Access**: Secure secret retrieval with managed identity

#### 2. Network Security
- **Private Endpoints**: All PaaS services use private endpoints
- **VNet Integration**: App Service integrated with virtual network
- **NSG Rules**: Network Security Groups with restrictive rules
- **HTTPS Only**: TLS 1.2+ enforced for all communications

#### 3. Data Protection
- **Encryption at Rest**: All data encrypted using Azure-managed keys
- **Encryption in Transit**: HTTPS/TLS for all communications
- **Database TDE**: Transparent Data Encryption enabled
- **Key Rotation**: Automatic key rotation policies

#### 4. Security Monitoring
- **Azure Defender**: Advanced threat protection enabled
- **Security Center**: Continuous security assessment
- **Audit Logs**: Comprehensive audit logging
- **Alert Rules**: Security incident alerting

### Security Checklist

- ✅ **Managed Identity** configured for database access
- ✅ **Private Endpoints** deployed for SQL Database and Key Vault
- ✅ **HTTPS Only** enforced on App Service
- ✅ **TLS 1.2+** minimum version configured
- ✅ **Azure AD Authentication** enabled for SQL Database
- ✅ **Key Vault** integration for secrets management
- ✅ **Network Security Groups** with restrictive rules
- ✅ **Azure Defender** enabled for all services
- ✅ **Audit Logging** configured and retained
- ✅ **Security Alerts** configured for critical events

## 📊 Monitoring

### Application Insights

The application includes comprehensive monitoring:

#### 1. Performance Monitoring
- **Response Times**: API endpoint performance tracking
- **Dependency Tracking**: Database and external service calls
- **Error Rates**: Application error monitoring
- **Availability Tests**: Synthetic monitoring from multiple regions

#### 2. Custom Metrics
- **User Activity**: User registration and activity metrics
- **Business Metrics**: Custom business logic metrics
- **System Health**: Database connection and system health
- **Security Events**: Authentication and authorization events

#### 3. Alerting Rules

| Alert | Condition | Severity | Action |
|-------|-----------|----------|--------|
| High Error Rate | >5% errors in 5 minutes | High | Email + SMS |
| Slow Response | >2s avg response time | Medium | Email |
| Database Connectivity | Connection failures | Critical | Email + SMS + PagerDuty |
| High CPU Usage | >80% CPU for 10 minutes | Medium | Email |

### Monitoring Dashboard

Access monitoring dashboards:
- **Application Insights**: Azure Portal → Application Insights → python-sql-insights-{env}
- **Azure Monitor**: Azure Portal → Monitor → Dashboards
- **Log Analytics**: Azure Portal → Log Analytics → log-python-sql-{env}

### Key Performance Indicators (KPIs)

Monitor these critical metrics:
- **Availability**: Target 99.9% uptime
- **Response Time**: <500ms 95th percentile
- **Error Rate**: <1% of requests
- **Database Performance**: <100ms query response time
- **Security Events**: Zero unauthorized access attempts

## 🔧 Troubleshooting

### Common Issues

#### 1. Database Connection Issues

**Symptom**: Application cannot connect to SQL Database
```
Error: Login failed for user 'NT AUTHORITY\ANONYMOUS LOGON'
```

**Solution**:
```powershell
# Verify managed identity is configured
az webapp identity show --name app-python-sql-prod --resource-group rg-python-sql-prod

# Check Azure AD admin on SQL Server
az sql server ad-admin list --resource-group rg-python-sql-prod --server-name sql-python-sql-prod

# Grant managed identity database access
sqlcmd -S your-server.database.windows.net -d python-sql-db -G
CREATE USER [app-python-sql-prod] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [app-python-sql-prod];
ALTER ROLE db_datawriter ADD MEMBER [app-python-sql-prod];
```

#### 2. Key Vault Access Issues

**Symptom**: Cannot retrieve secrets from Key Vault
```
Error: Access denied to Key Vault 'kv-python-sql-prod'
```

**Solution**:
```powershell
# Grant managed identity Key Vault access
az keyvault set-policy \
  --name kv-python-sql-prod \
  --object-id $(az webapp identity show --name app-python-sql-prod --resource-group rg-python-sql-prod --query principalId -o tsv) \
  --secret-permissions get list
```

#### 3. Network Connectivity Issues

**Symptom**: Private endpoint connectivity failures
```
Error: Name or service not known
```

**Solution**:
```powershell
# Verify VNet integration
az webapp vnet-integration list --name app-python-sql-prod --resource-group rg-python-sql-prod

# Check private endpoint configuration
az network private-endpoint show --resource-group rg-python-sql-prod --name pe-sql-python-sql-prod

# Test DNS resolution
nslookup sql-python-sql-prod.database.windows.net
```

#### 4. Application Performance Issues

**Symptom**: Slow response times or high resource usage

**Diagnostic Steps**:
```powershell
# Check Application Insights metrics
az monitor app-insights metrics show \
  --app python-sql-insights-prod \
  --resource-group rg-python-sql-prod \
  --metrics requests/duration

# Review application logs  
az webapp log tail --name app-python-sql-prod --resource-group rg-python-sql-prod

# Check resource utilization
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-python-sql-prod/providers/Microsoft.Web/sites/app-python-sql-prod \
  --metric CpuPercentage,MemoryPercentage
```

### Debugging Commands

```powershell
# Get application settings
az webapp config appsettings list --name app-python-sql-prod --resource-group rg-python-sql-prod

# Stream application logs
az webapp log tail --name app-python-sql-prod --resource-group rg-python-sql-prod --provider application

# Connect to SQL Database
sqlcmd -S sql-python-sql-prod.database.windows.net -d python-sql-db -G

# Test Key Vault connectivity  
az keyvault secret show --vault-name kv-python-sql-prod --name sql-connection-string

# Check managed identity token
curl -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://database.windows.net/"
```

### Support Resources

- **Azure Support**: Create support ticket in Azure Portal
- **Documentation**: [Azure App Service Docs](https://docs.microsoft.com/azure/app-service/)
- **Community**: [Microsoft Q&A](https://docs.microsoft.com/answers/)
- **GitHub Issues**: Report issues in this repository

## 🤝 Contributing

### Development Setup

1. **Fork and Clone**
```powershell
git clone https://github.com/your-username/terraform_azure_template.git
cd terraform_azure_template
```

2. **Setup Development Environment**
```powershell
# Install Python dependencies
cd src
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Setup pre-commit hooks
pre-commit install
```

3. **Local Development**
```powershell
# Run application locally
cd src
flask run --debug

# Run tests
pytest tests/ -v

# Format and lint code
black .
flake8 .
```

### Contribution Guidelines

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** to branch (`git push origin feature/amazing-feature`)  
5. **Open** a Pull Request

### Code Standards

- **Python**: Follow PEP 8 style guide
- **Terraform**: Use consistent formatting (`terraform fmt`)
- **Documentation**: Update README and inline comments
- **Testing**: Include unit tests for new features
- **Security**: Follow security best practices

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Azure Well-Architected Framework** for architectural guidance
- **Azure CAF** for naming conventions and best practices  
- **Terraform Azure Provider** for infrastructure automation
- **Flask Community** for the excellent web framework

---

**🚀 Ready to deploy secure, scalable Python applications on Azure!**

For questions or support, please [open an issue](https://github.com/your-username/terraform_azure_template/issues) or contact the maintainers.