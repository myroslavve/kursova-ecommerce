# =============================================================================
# envs/gcp/outputs.tf
# =============================================================================

output "backend_url" {
  description = "Cloud Run backend service URL"
  value       = module.compute.backend_cloud_run_url
}

output "frontend_url" {
  description = "Cloud Run frontend service URL"
  value       = module.compute.frontend_cloud_run_url
}

output "ar_backend_url" {
  description = "Artifact Registry URL for backend images"
  value       = module.registry.ar_urls["backend"]
}

output "ar_frontend_url" {
  description = "Artifact Registry URL for frontend images"
  value       = module.registry.ar_urls["frontend"]
}

output "cloudsql_connection_name" {
  description = "Cloud SQL connection name (for Cloud SQL Auth Proxy)"
  value       = module.db.cloudsql_connection_name
}
