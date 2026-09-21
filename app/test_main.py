import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_root_endpoint():
    """Test root endpoint returns service metadata and 200 OK."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "Container Delivery Platform Microservice"
    assert "git_commit_sha" in data
    assert "uptime_seconds" in data

def test_health_endpoint():
    """Test /health probe returns HTTP 200 and status UP."""
    # Ensure health is restored before testing
    client.post("/chaos/restore-health")
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "UP"

def test_version_endpoint():
    """Test /version endpoint exposes release metadata."""
    response = client.get("/version")
    assert response.status_code == 200
    data = response.json()
    assert "git_commit_sha" in data
    assert "release_version" in data

def test_chaos_toggle():
    """Test chaos engineering simulation toggles health from 200 to 503 and back."""
    # 1. Trigger failure
    fail_res = client.post("/chaos/fail-health")
    assert fail_res.status_code == 200
    assert fail_res.json()["chaos_active"] is True

    # 2. Verify health returns 503
    health_res = client.get("/health")
    assert health_res.status_code == 503

    # 3. Restore health
    restore_res = client.post("/chaos/restore-health")
    assert restore_res.status_code == 200
    assert restore_res.json()["chaos_active"] is False

    # 4. Verify health returns 200 again
    health_restored = client.get("/health")
    assert health_restored.status_code == 200
