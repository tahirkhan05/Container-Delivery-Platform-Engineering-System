import os
import time
from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel

# ==============================================================================
# CONTAINER DELIVERY PLATFORM - SAMPLE SERVICE WITH DEPLOYMENT TRACING
# ==============================================================================
# Key Features for Project 2:
# 1. Release Tracing: Injects and exposes the Git Commit SHA, allowing operators
#    to trace any running container directly back to the GitHub commit.
# 2. Chaos Engineering Endpoints: Allows simulating a bad release (unhealthy /health)
#    to test AWS ECS Deployment Circuit Breaker automated rollbacks.
# ==============================================================================

app = FastAPI(
    title="Container Delivery & Platform Engineering API",
    description="Production-Grade ECS/Fargate Deployment Platform with Automated Rollback",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Deployment and runtime metadata
START_TIME = time.time()
RELEASE_VERSION = os.getenv("RELEASE_VERSION", "v1.0.0")
GIT_COMMIT_SHA = os.getenv("GIT_COMMIT_SHA", "dev-local-build")
ENVIRONMENT = os.getenv("APP_ENV", "production")

# Global health state (can be modified via chaos endpoints for resilience drills)
CHAOS_HEALTH_OVERRIDE = False


# ==============================================================================
# OBSERVABILITY & DEPLOYMENT TRACING ENDPOINTS
# ==============================================================================

@app.get("/", tags=["Release Information"])
def root():
    """
    Returns deployment metadata, including the immutable Git Commit SHA,
    environment, uptime, and system status.
    """
    return {
        "service": "Container Delivery Platform Microservice",
        "status": "healthy" if not CHAOS_HEALTH_OVERRIDE else "degraded",
        "environment": ENVIRONMENT,
        "release_version": RELEASE_VERSION,
        "git_commit_sha": GIT_COMMIT_SHA,
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "docs": "/docs"
    }


@app.get("/version", tags=["Release Information"])
def get_version():
    """
    Returns the exact immutable Git commit SHA and release version.
    Used by CI/CD pipelines to verify deployment completion.
    """
    return {
        "release_version": RELEASE_VERSION,
        "git_commit_sha": GIT_COMMIT_SHA,
        "deployed_at": datetime.now(timezone.utc).isoformat()
    }


@app.get("/health", tags=["Observability"])
def health_check():
    """
    Liveness and Readiness probe for the AWS Application Load Balancer (ALB).
    - Returns HTTP 200 OK under normal operation.
    - Returns HTTP 503 Service Unavailable if Chaos mode is enabled, triggering
      ALB health failure and ECS Deployment Circuit Breaker automated rollback.
    """
    if CHAOS_HEALTH_OVERRIDE:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "UNHEALTHY",
                "reason": "Simulated deployment health failure (Chaos Drill)",
                "git_commit_sha": GIT_COMMIT_SHA
            }
        )
    return {
        "status": "UP",
        "git_commit_sha": GIT_COMMIT_SHA,
        "uptime_seconds": round(time.time() - START_TIME, 2)
    }


# ==============================================================================
# CHAOS DRILL / FAILURE SIMULATION ENDPOINTS
# ==============================================================================

@app.post("/chaos/fail-health", tags=["Chaos Testing"])
def trigger_unhealthy():
    """
    Forces /health to return HTTP 503.
    Used in failure drills to observe ALB marking the target unhealthy and
    ECS deploying replacement tasks or triggering deployment rollback.
    """
    global CHAOS_HEALTH_OVERRIDE
    CHAOS_HEALTH_OVERRIDE = True
    return {
        "message": "Health status set to FAILING (HTTP 503). ALB will detect target as unhealthy.",
        "chaos_active": True
    }


@app.post("/chaos/restore-health", tags=["Chaos Testing"])
def restore_healthy():
    """
    Restores /health to return HTTP 200 OK.
    """
    global CHAOS_HEALTH_OVERRIDE
    CHAOS_HEALTH_OVERRIDE = False
    return {
        "message": "Health status RESTORED to normal (HTTP 200).",
        "chaos_active": False
    }


# ==============================================================================
# SAMPLE BUSINESS LOGIC ENDPOINT
# ==============================================================================

class MessagePayload(BaseModel):
    title: str
    content: str

@app.get("/api/items", tags=["Application"])
def list_items():
    return [
        {"id": 1, "name": "Cloud Deployment Pipeline", "status": "ACTIVE"},
        {"id": 2, "name": "Immutable Container Image", "status": "SCANNED"},
        {"id": 3, "name": "ECS Fargate Task Replica", "status": "RUNNING"}
    ]
