variable "cloud" {
  description = "Target cloud: 'aws' or 'gcp'"
  type        = string
  validation {
    condition     = contains(["aws", "gcp"], var.cloud)
    error_message = "cloud must be 'aws' or 'gcp'."
  }
}

variable "project_name" {
  description = "Short project identifier used in all resource names"
  type        = string
  default     = "cubestore"
}

variable "environment" {
  description = "Deployment environment: dev | staging | prod"
  type        = string
  default     = "prod"
}

# ── AWS-specific ─────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region (used only when cloud = 'aws')"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# ── GCP-specific ─────────────────────────────────────────────────────────────
variable "gcp_project" {
  description = "GCP project ID (used only when cloud = 'gcp')"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region (used only when cloud = 'gcp')"
  type        = string
  default     = "europe-west3"
}

variable "connector_cidr" {
  description = "CIDR for the Serverless VPC Access Connector (/28 required by GCP)"
  type        = string
  default     = "10.8.0.0/28"
}
