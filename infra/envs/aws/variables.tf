# =============================================================================
# envs/aws/variables.tf
# =============================================================================

variable "project_name" {
  type    = string
  default = "cubestore"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
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

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "redis_host" {
  type    = string
  default = "redis"
}

variable "redis_port" {
  type    = string
  default = "6379"
}

variable "backend_image" {
  description = "Full ECR image URL for the backend, e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/cubestore/backend:v1.0.0"
  type        = string
}

variable "frontend_image" {
  description = "Full ECR image URL for the frontend"
  type        = string
}
