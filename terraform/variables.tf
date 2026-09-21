variable "aws_region" {
  type        = string
  description = "AWS Region for deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "production"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for naming and tagging resources"
  default     = "container-platform"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name (format: username/repo)"
  default     = "tahirkhan05/Container-Delivery-Platform-Engineering-System"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (ALB & NAT Gateway)"
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (ECS Fargate tasks)"
  default     = ["10.1.11.0/24", "10.1.12.0/24"]
}

variable "app_port" {
  type        = number
  description = "Application listening port"
  default     = 8000
}

variable "app_count" {
  type        = number
  description = "Desired number of ECS task replicas across Availability Zones"
  default     = 2
}

variable "fargate_cpu" {
  type        = string
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  default     = "256"
}

variable "fargate_memory" {
  type        = string
  description = "Fargate task RAM in MB"
  default     = "512"
}
