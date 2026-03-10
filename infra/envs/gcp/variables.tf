# =============================================================================
# envs/gcp/variables.tf
# =============================================================================

variable "project_name" {
  type    = string
  default = "cubestore"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "gcp_project" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west3"
}

variable "connector_cidr" {
  description = "/28 CIDR for the Serverless VPC Access Connector"
  type        = string
  default     = "10.8.0.0/28"
}

variable "db_username" {
  type    = string
  default = "cubestore"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "cubestore"
}

variable "cloudsql_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}

variable "memorystore_host" {
  description = "GCP Memorystore (Redis) private IP — provisioned separately in step 2.4"
  type        = string
  default     = "127.0.0.1"
}

variable "backend_image" {
  description = "Full Artifact Registry image URL for the backend"
  type        = string
}

variable "frontend_image" {
  description = "Full Artifact Registry image URL for the frontend"
  type        = string
}
