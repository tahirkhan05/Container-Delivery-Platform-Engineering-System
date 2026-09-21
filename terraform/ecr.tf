# ==============================================================================
# AMAZON ECR (ELASTIC CONTAINER REGISTRY)
# ==============================================================================
# - Automated Vulnerability Scanning on push (scan_on_push = true).
# - Lifecycle policies keeping the last 15 immutable images to optimize storage.
# ==============================================================================

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE" # Allows tagging both Git SHA and 'latest'
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain last 15 immutable container images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 15
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
