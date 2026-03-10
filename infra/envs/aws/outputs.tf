# =============================================================================
# envs/aws/outputs.tf
# =============================================================================

output "alb_dns_name" {
  description = "Public DNS of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "ecr_backend_url" {
  description = "ECR repository URL for the backend image"
  value       = module.registry.ecr_urls["backend"]
}

output "ecr_frontend_url" {
  description = "ECR repository URL for the frontend image"
  value       = module.registry.ecr_urls["frontend"]
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.db.rds_endpoint
  sensitive   = true
}
