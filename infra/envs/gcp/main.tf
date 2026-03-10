# =============================================================================
# envs/gcp/main.tf — GCP environment root module
#
# Wires up all shared modules for the GCP (secondary / failover) cloud.
# Remote state is stored in GCS (configured via backend "gcs" block below).
# =============================================================================

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.25"
    }
  }

  # ── Remote state (GCS) ────────────────────────────────────────────────────
  # Create the bucket first:
  #   gcloud storage buckets create gs://cubestore-tf-state-gcp \
  #     --location=europe-west3 --uniform-bucket-level-access
  # Then run: terraform init
  backend "gcs" {
    bucket = "cubestore-tf-state-gcp"   # ← replace with your GCS bucket name
    prefix = "gcp/terraform.tfstate"
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region

  # Credentials come from GOOGLE_APPLICATION_CREDENTIALS env var
  # or from `gcloud auth application-default login`
}

# ── Network (VPC Access Connector) ────────────────────────────────────────────
module "network" {
  source = "../../modules/network"

  cloud        = "gcp"
  project_name = var.project_name
  environment  = var.environment
  gcp_project  = var.gcp_project
  gcp_region   = var.gcp_region
  connector_cidr = var.connector_cidr
}

# ── Container Registry (Artifact Registry) ────────────────────────────────────
module "registry" {
  source = "../../modules/registry"

  cloud        = "gcp"
  project_name = var.project_name
  environment  = var.environment
  gcp_project  = var.gcp_project
  gcp_region   = var.gcp_region
}

# ── Database (Cloud SQL PostgreSQL — Read Replica / Standby) ──────────────────
module "db" {
  source = "../../modules/db"

  cloud        = "gcp"
  project_name = var.project_name
  environment  = var.environment
  gcp_project  = var.gcp_project
  gcp_region   = var.gcp_region

  db_username   = var.db_username
  db_password   = var.db_password
  db_name       = var.db_name
  cloudsql_tier = var.cloudsql_tier
}

# ── Compute (Cloud Run) ───────────────────────────────────────────────────────
module "compute" {
  source = "../../modules/compute"

  cloud          = "gcp"
  project_name   = var.project_name
  environment    = var.environment
  gcp_project    = var.gcp_project
  gcp_region     = var.gcp_region

  backend_image  = var.backend_image
  frontend_image = var.frontend_image

  backend_env = {
    # Cloud Run connects to Cloud SQL via private IP through the VPC Connector
    DATABASE_URL = "postgresql://${var.db_username}:${var.db_password}@${module.db.cloudsql_private_ip}:5432/${var.db_name}"
    REDIS_HOST   = var.memorystore_host
    REDIS_PORT   = "6379"
    PORT         = "3000"
    CORS_ORIGIN  = module.compute.frontend_cloud_run_url
  }

  frontend_env = {
    API_BASE_INTERNAL    = "${module.compute.backend_cloud_run_url}/api"
    NUXT_PUBLIC_API_BASE = "${module.compute.backend_cloud_run_url}/api"
  }

  vpc_connector_id = module.network.vpc_connector_id
}
