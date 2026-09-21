# 🧪 Platform Engineering Operations & Chaos Runbook

## Drill 1: Deployment Tracing (Commit SHA Verification)

1. Get your live ALB URL:
   ```powershell
   $ALB = (terraform -chdir=terraform output -raw alb_dns_name)
   ```

2. Query the live `/version` endpoint:
   ```powershell
   Invoke-RestMethod -Uri "$ALB/version"
   ```
   **Output shows:**
   - `release_version`: Current semantic release.
   - `git_commit_sha`: The exact Git commit deployed.

---

## Drill 2: Chaos Engineering - Live Automated Rollback Test

In this drill, we demonstrate how the platform protects production traffic when a broken deployment or health degradation occurs.

### Step 1: Simulate Health Failure
```powershell
Invoke-RestMethod -Uri "$ALB/chaos/fail-health" -Method Post
```

### Step 2: Observe ALB Health Detection
```powershell
Invoke-RestMethod -Uri "$ALB/health"
```
*(Returns HTTP 503 Service Unavailable)*

### Step 3: Observe CloudWatch Failover
1. Open your [CloudWatch Dashboard](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=container-platform-delivery-dashboard).
2. The `Healthy vs Unhealthy Target Replicas` widget will show the unhealthy count spike and the ALB routing traffic only to surviving replicas.

### Step 4: Restore Health
```powershell
Invoke-RestMethod -Uri "$ALB/chaos/restore-health" -Method Post
```

---

## Drill 3: Single-Command Clean Teardown
To destroy all provisioned cloud resources and maintain a $0 AWS bill:
```powershell
terraform -chdir=terraform destroy -auto-approve
```
