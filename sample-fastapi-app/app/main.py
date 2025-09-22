"""
FastAPI Azure Sample Application

This sample application demonstrates how to use FastAPI with:
- Azure SQL Database for relational data
- Azure Cosmos DB for NoSQL data
- Azure Key Vault for secrets management
- Azure Application Insights for monitoring
- Managed Identity for secure authentication
"""

import os
import logging
from typing import Dict, Any
from datetime import datetime

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from routers import health, sql_routes, cosmos_routes
from database.sql_database import get_sql_engine
from database.cosmos_database import get_cosmos_client

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Application metadata
app = FastAPI(
    title="FastAPI Azure Demo",
    description="Sample FastAPI application with Azure SQL Database and Cosmos DB",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS configuration
cors_origins = os.getenv("CORS_ALLOWED_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, tags=["Health"])
app.include_router(sql_routes.router, prefix="/api/sql", tags=["SQL Database"])
app.include_router(cosmos_routes.router, prefix="/api/cosmos", tags=["Cosmos DB"])

@app.on_event("startup")
async def startup_event():
    """Initialize application on startup"""
    logger.info("FastAPI application starting up...")
    logger.info(f"Environment: {os.getenv('FASTAPI_ENV', 'development')}")
    logger.info(f"Debug mode: {os.getenv('DEBUG', 'false')}")
    
    # Test database connections
    try:
        # Test SQL connection
        sql_engine = get_sql_engine()
        logger.info("SQL Database connection established")
        
        # Test Cosmos DB connection
        cosmos_client = get_cosmos_client()
        logger.info("Cosmos DB connection established")
        
    except Exception as e:
        logger.error(f"Database connection error: {e}")

@app.on_event("shutdown")
async def shutdown_event():
    """Clean up on application shutdown"""
    logger.info("FastAPI application shutting down...")

@app.get("/", response_model=Dict[str, Any])
async def root():
    """Root endpoint with application information"""
    return {
        "message": "FastAPI Azure Sample Application",
        "version": "1.0.0",
        "environment": os.getenv("FASTAPI_ENV", "development"),
        "timestamp": datetime.utcnow().isoformat(),
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "sql_api": "/api/sql",
            "cosmos_api": "/api/cosmos"
        }
    }

@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler"""
    logger.error(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "message": "An unexpected error occurred"
        }
    )

if __name__ == "__main__":
    import uvicorn
    
    # Configuration for local development
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug,
        log_level="info"
    )