# 📘 The Platform Engineering & CI/CD Masterclass
### Concepts, Real-World Architecture, Commands, Code Annotations & Interview Prep

Welcome to **Project 2: Dedicated ECS/Fargate + Terraform + CI/CD Platform**!
This guide breaks down modern software delivery, container release engineering, automated rollbacks, and observability in clear, beginner-friendly language.

---

## 📑 Table of Contents
1. [The Platform Engineering Mental Model](#1-the-platform-engineering-mental-model)
2. [Why Immutable Tags Matter (Git Commit SHA)](#2-why-immutable-tags-matter-git-commit-sha)
3. [Zero-Downtime Rolling Deployments vs Rollbacks](#3-zero-downtime-rolling-deployments-vs-rollbacks)
4. [AWS CodePipeline vs GitHub Actions](#4-aws-codepipeline-vs-github-actions)
5. [What Every Command & File Does](#5-what-every-command--file-does)
6. [How to Ace an Interview on This Project](#6-how-to-ace-an-interview-on-this-project)

---

## 1. The Platform Engineering Mental Model

In traditional software development, developers had to manually SSH into servers, run `git pull`, and restart background processes. This led to outages, configuration drift, and zero deployment tracking.

**Platform Engineering** solves this by building an automated "delivery highway":
```
[ Developer Push ] ──► [ Automated CI Tests ] ──► [ Immutable Image Build ]
                                                             │
                                                             ▼
[ Live Traffic Served ] ◄── [ ALB Health Check ] ◄── [ ECS Rolling Update ]
                                     │
                             (If Health Fails)
                                     │
                                     ▼
                    [ Circuit Breaker Instant Rollback! ]
```

---

## 2. Why Immutable Tags Matter (Git Commit SHA)

### The Anti-Pattern: Using `:latest` Everywhere
If you only tag Docker images with `latest`:
- You have no idea which code version is currently running on which server.
- If a bug happens in production, you cannot roll back to the exact previous image because `latest` was overwritten.

### The Production Standard: Git Commit SHA Tagging
- Every Git commit has a unique cryptographic hash (e.g., `f49ca9f`).
- We tag our Docker image: `container-platform-app:f49ca9f`.
- **Traceability:** You can look at an ECS task in AWS, read the image tag `f49ca9f`, and instantly view the exact Git commit and code diff on GitHub!

---

## 3. Zero-Downtime Rolling Deployments vs Rollbacks

### A. Zero-Downtime Rolling Update (200% Max, 100% Min)
1. You have 2 running tasks (Version A).
2. You deploy Version B.
3. ECS launches 2 new tasks (Version B) alongside Version A (total capacity temporarily reaches 200%).
4. The ALB sends health checks to `/health` on Version B.
5. Once Version B passes 2 consecutive health checks, ALB switches incoming user traffic to Version B.
6. ECS terminates the old Version A tasks. **Zero downtime for users!**

### B. Deployment Circuit Breaker & Instant Rollback
- What if a developer accidentally commits a bug that crashes the app on startup?
- Without a circuit breaker, ECS would shut down healthy tasks and replace them with broken ones, causing a major outage!
- **With ECS Circuit Breaker:** ECS detects that Version B failed health checks 3 times. It automatically **cancels the deployment and rolls back**, keeping the healthy Version A tasks alive!

---

## 4. AWS CodePipeline vs GitHub Actions

| Feature | AWS CodePipeline + CodeBuild | GitHub Actions |
|---|---|---|
| **Ecosystem** | Native AWS service, integrated with IAM & CloudTrail | Integrated directly into GitHub PRs and Commits |
| **Authentication** | Native IAM roles (no credentials needed) | AWS IAM OIDC (OpenID Connect) or IAM Secrets |
| **Artifacts** | Stored in private encrypted Amazon S3 buckets | GitHub workspace caching |
| **Best Used For** | Organizations strictly standardizing on AWS native tools | Teams wanting fast developer feedback inside GitHub |

*In this project, we provide configurations for **both** AWS CodeBuild (`buildspec.yml`) and GitHub Actions (`.github/workflows/deploy.yml`)!*

---

## 5. What Every Command & File Does

### Application (`app/`):
- `main.py`: Exposes `/`, `/version` (with commit SHA), `/health` probe, and `/chaos/fail-health` failure toggle.
- `test_main.py`: Pytest automated unit tests enforcing test quality before Docker build.
- `Dockerfile`: Multi-stage, non-root Linux container.
- `buildspec.yml`: AWS CodeBuild instructions for testing, building, and pushing container images.

### Terraform (`terraform/`):
- `vpc.tf`: Multi-AZ VPC across 2 Availability Zones with Public/Private subnets and NAT Gateway.
- `ecr.tf`: Amazon ECR repository with automated vulnerability scanning on push.
- `alb.tf`: Application Load Balancer with health checks.
- `ecs.tf`: ECS Fargate cluster with Deployment Circuit Breaker and CPU Auto-Scaling.
- `codepipeline.tf`: S3 artifact bucket and AWS CodeBuild project.
- `cloudwatch.tf`: Real-time deployment telemetry dashboard and metric alarms.

---

## 6. How to Ace an Interview on This Project

> *"I engineered an automated container delivery platform on AWS using Terraform, ECS Fargate, Amazon ECR, Application Load Balancers, and GitHub Actions / AWS CodePipeline.*
> 
> *The platform enforces strict release engineering practices: every commit triggers automated unit testing, builds an immutable Docker image tagged with the Git commit SHA, and performs vulnerability scanning in ECR.*
> 
> *Deployments use zero-downtime rolling updates verified by ALB health check probes. To guarantee resilience, I configured AWS ECS Deployment Circuit Breakers with automated rollback—if a new deployment fails health checks, the platform automatically halts the rollout and rolls back to the previous stable release without user interruption."*
