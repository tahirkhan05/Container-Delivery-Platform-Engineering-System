# Architecture Decision Records (ADRs) - Project 2

## ADR 001: Immutable Container Tagging by Git Commit SHA
- **Status:** Accepted
- **Context:** Tagging images only as `latest` causes non-deterministic deployments and prevents reliable auditing and rollbacks.
- **Decision:** Every image built in CI is tagged with the 40-character or 7-character Git Commit SHA (`$GITHUB_SHA` / `$CODEBUILD_RESOLVED_SOURCE_VERSION`).
- **Consequences:** 100% auditable release tracing from running ECS task back to the exact code commit in GitHub.

## ADR 002: ECS Deployment Circuit Breakers with Auto-Rollback
- **Status:** Accepted
- **Context:** Bad releases with broken health checks must never take down production.
- **Decision:** Enable `deployment_circuit_breaker { enable = true, rollback = true }` in ECS Service.
- **Consequences:** Automatic detection of unhealthy targets during rolling update, halting the deployment and reverting to the last stable task definition without human intervention.

## ADR 003: Dual CI/CD Pipeline Support (CodePipeline & GitHub Actions)
- **Status:** Accepted
- **Context:** Cloud engineers need expertise in both native AWS developer tools and standard open-source CI/CD ecosystems.
- **Decision:** Codify AWS CodeBuild project and S3 artifacts in Terraform while providing a complete GitHub Actions workflow.
- **Consequences:** Maximizes versatility and portfolio positioning for enterprise and startup cloud environments.
