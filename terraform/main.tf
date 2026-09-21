# ==============================================================================
# TERRAFORM CONFIGURATION - PROJECT 2: CONTAINER DELIVERY PLATFORM
# ==============================================================================
# This configuration provisions the entire cloud platform infrastructure:
# - Multi-AZ Networking (VPC, Subnets, NAT Gateway)
# - Container Orchestration (AWS ECS Fargate)
# - Container Registry (Amazon ECR)
# - Traffic Distribution & Health Verification (Application Load Balancer)
# - CI/CD Automation (AWS CodePipeline, CodeBuild & GitHub Actions OIDC)
# - Centralized Telemetry & Alarms (Amazon CloudWatch)
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = var.github_repository
    }
  }
}

# Fetch caller identity (AWS Account ID) for IAM policies and ECR URIs
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
