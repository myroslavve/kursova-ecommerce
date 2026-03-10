variable "cloud"        { type = string }
variable "project_name" { type = string; default = "cubestore" }
variable "environment"  { type = string; default = "prod" }
variable "gcp_project"  { type = string; default = "" }
variable "gcp_region"   { type = string; default = "europe-west3" }

locals {
  reg_aws = var.cloud == "aws"
  reg_gcp = var.cloud == "gcp"
  services = ["backend", "frontend"]
}

resource "aws_ecr_repository" "repos" {
  for_each = local.reg_aws ? toset(local.services) : toset([])

  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Environment = var.environment }
}

resource "aws_ecr_lifecycle_policy" "repos" {
  for_each   = aws_ecr_repository.repos
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep last 10 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}

resource "google_artifact_registry_repository" "repos" {
  for_each = local.reg_gcp ? toset(local.services) : toset([])

  project       = var.gcp_project
  location      = var.gcp_region
  repository_id = "${var.project_name}-${each.key}"
  description   = "Docker images for ${each.key}"
  format        = "DOCKER"

  labels = { environment = var.environment }
}

output "ecr_urls" {
  description = "Map of service → ECR repository URL (AWS only)"
  value       = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
}

output "ar_urls" {
  description = "Map of service → Artifact Registry URL (GCP only)"
  value = {
    for k, v in google_artifact_registry_repository.repos :
    k => "${v.location}-docker.pkg.dev/${v.project}/${v.repository_id}"
  }
}
