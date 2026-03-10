terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90"
    }
  }


  backend "s3" {
    bucket         = "cubestore-tf-state"     # ← replace with your bucket name
    key            = "aws/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "cubestore-tf-locks"     # ← create this table, PK = LockID (String)
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ── Network ───────────────────────────────────────────────────────────────────
module "network" {
  source = "../../modules/network"

  cloud        = "aws"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ── Container Registry ────────────────────────────────────────────────────────
module "registry" {
  source = "../../modules/registry"

  cloud        = "aws"
  project_name = var.project_name
  environment  = var.environment
}

# ── Database (RDS PostgreSQL — Primary) ───────────────────────────────────────
module "db" {
  source = "../../modules/db"

  cloud      = "aws"
  project_name = var.project_name
  environment  = var.environment

  db_username = var.db_username
  db_password = var.db_password
  db_name     = var.db_name

  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.network.rds_sg_id
  multi_az           = var.environment == "prod"
  db_instance_class  = var.db_instance_class
}

# ── Compute (ECS Fargate) ─────────────────────────────────────────────────────
module "compute" {
  source = "../../modules/compute"

  cloud          = "aws"
  project_name   = var.project_name
  environment    = var.environment
  aws_region     = var.aws_region

  backend_image  = var.backend_image
  frontend_image = var.frontend_image

  backend_env = {
    DATABASE_URL = "postgresql://${var.db_username}:${var.db_password}@${module.db.rds_endpoint}/${var.db_name}"
    REDIS_HOST   = var.redis_host
    REDIS_PORT   = var.redis_port
    PORT         = "3000"
    CORS_ORIGIN  = "http://${module.compute.alb_dns_name}"
  }

  frontend_env = {
    API_BASE_INTERNAL    = "http://${module.compute.alb_dns_name}/api"
    NUXT_PUBLIC_API_BASE = "http://${module.compute.alb_dns_name}/api"
  }

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  ecs_tasks_sg_id    = module.network.ecs_tasks_sg_id
}
