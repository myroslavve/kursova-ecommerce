# =============================================================================
# modules/db — Managed PostgreSQL
#
# AWS → RDS PostgreSQL 16 (Multi-AZ in prod, single-AZ in dev)
# GCP → Cloud SQL PostgreSQL 16
#
# Replication strategy (Active-Standby):
#   Primary lives in AWS. GCP Cloud SQL is configured as a Read Replica via
#   external replication (logical replication from AWS RDS).
#   In a future Active-Active setup both instances would be writable.
# =============================================================================

variable "cloud"               { type = string }
variable "project_name"        { type = string; default = "cubestore" }
variable "environment"         { type = string; default = "prod" }
variable "db_username"         { type = string; default = "cubestore" }
variable "db_password"         { type = string; sensitive = true }
variable "db_name"             { type = string; default = "cubestore" }

# AWS-specific
variable "private_subnet_ids"  { type = list(string); default = [] }
variable "rds_sg_id"           { type = string; default = "" }
variable "multi_az"            { type = bool; default = false }
variable "db_instance_class"   { type = string; default = "db.t3.micro" }

# GCP-specific
variable "gcp_project"         { type = string; default = "" }
variable "gcp_region"          { type = string; default = "europe-west3" }
variable "cloudsql_tier"       { type = string; default = "db-f1-micro" }

locals {
  db_aws = var.cloud == "aws"
  db_gcp = var.cloud == "gcp"
  name   = "${var.project_name}-${var.environment}"
}

# ── AWS RDS PostgreSQL ─────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "main" {
  count      = local.db_aws ? 1 : 0
  name       = "${local.name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "${local.name}-db-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  count = local.db_aws ? 1 : 0

  identifier        = "${local.name}-postgres"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [var.rds_sg_id]

  # Enable logical replication so GCP replica can subscribe
  parameter_group_name = aws_db_parameter_group.postgres[0].name

  multi_az                = var.multi_az
  backup_retention_period = 7
  skip_final_snapshot     = var.environment != "prod"
  deletion_protection     = var.environment == "prod"

  tags = { Environment = var.environment }
}

resource "aws_db_parameter_group" "postgres" {
  count  = local.db_aws ? 1 : 0
  name   = "${local.name}-pg16-params"
  family = "postgres16"

  parameter {
    name  = "rds.logical_replication"
    value = "1"
    apply_method = "pending-reboot"
  }

  tags = { Environment = var.environment }
}

# ── GCP Cloud SQL PostgreSQL ───────────────────────────────────────────────────
resource "google_sql_database_instance" "postgres" {
  count = local.db_gcp ? 1 : 0

  name             = "${local.name}-postgres"
  project          = var.gcp_project
  region           = var.gcp_region
  database_version = "POSTGRES_16"

  deletion_protection = var.environment == "prod"

  settings {
    tier = var.cloudsql_tier

    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.gcp_project}/global/networks/default"
    }
  }
}

resource "google_sql_database" "db" {
  count    = local.db_gcp ? 1 : 0
  name     = var.db_name
  instance = google_sql_database_instance.postgres[0].name
  project  = var.gcp_project
}

resource "google_sql_user" "app" {
  count    = local.db_gcp ? 1 : 0
  name     = var.db_username
  password = var.db_password
  instance = google_sql_database_instance.postgres[0].name
  project  = var.gcp_project
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "rds_endpoint" {
  description = "AWS RDS connection endpoint (null on GCP)"
  value       = try(aws_db_instance.postgres[0].endpoint, null)
}

output "cloudsql_connection_name" {
  description = "GCP Cloud SQL connection name for Cloud Run sidecar (null on AWS)"
  value       = try(google_sql_database_instance.postgres[0].connection_name, null)
}

output "cloudsql_private_ip" {
  description = "GCP Cloud SQL private IP (null on AWS)"
  value       = try(google_sql_database_instance.postgres[0].private_ip_address, null)
}
