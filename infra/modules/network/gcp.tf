locals {
  gcp = var.cloud == "gcp"
}

# ── Serverless VPC Access Connector ───────────────────────────────────────────
# Allows Cloud Run services to reach Cloud SQL and Memorystore on a private
# VPC without a public IP. The connector lives in a /28 CIDR range that must
# not overlap with any existing subnet.
resource "google_vpc_access_connector" "connector" {
  count = local.gcp ? 1 : 0

  name          = "${var.project_name}-${var.environment}-connector"
  project       = var.gcp_project
  region        = var.gcp_region
  ip_cidr_range = var.connector_cidr
  network       = "default"

  min_throughput = 200  # Mbps
  max_throughput = 1000 # Mbps
}
