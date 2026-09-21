output "alb_dns_name" {
  description = "Public URL to access the live deployed microservice"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecr_repository_url" {
  description = "Amazon ECR Repository URL for immutable container image tags"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.main.name
}

output "codebuild_project_name" {
  description = "AWS CodeBuild Project Name"
  value       = aws_codebuild_project.app.name
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch Telemetry & Deployment Dashboard Link"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}
