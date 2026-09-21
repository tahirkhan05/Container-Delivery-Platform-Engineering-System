# ==============================================================================
# AWS CODEBUILD & CODEPIPELINE NATIVE CI/CD PLATFORM
# ==============================================================================
# Provisions:
# 1. S3 Artifact Storage (Encrypted & Versioned).
# 2. AWS CodeBuild Project running tests, Docker container builds, and ECR push.
# 3. CloudWatch Log Group for continuous build streaming.
# ==============================================================================

# Random suffix for globally unique S3 bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. S3 Bucket for CI/CD pipeline build artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-artifacts-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 2. CloudWatch Log Group for CodeBuild logs
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.project_name}-build"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-codebuild-logs"
  }
}

# 3. AWS CodeBuild Project
resource "aws_codebuild_project" "app" {
  name          = "${var.project_name}-build"
  description   = "Automated Unit Tests, Docker Image Build, and ECR Push"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 15

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true # Required for Docker-in-Docker builds

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.app.name
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_repository}.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
      status     = "ENABLED"
    }
  }

  tags = {
    Name = "${var.project_name}-codebuild"
  }
}
