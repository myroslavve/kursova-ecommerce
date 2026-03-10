# =============================================================================
# modules/compute — Container runtime
#
# AWS → ECS Cluster + Fargate task definitions + ALB
# GCP → Cloud Run services (backend + frontend)
#
# Both accept the same image URLs + env var maps and expose an HTTPS endpoint.
# =============================================================================

variable "cloud"            { type = string }
variable "project_name"     { type = string; default = "cubestore" }
variable "environment"      { type = string; default = "prod" }
variable "backend_image"    { type = string }
variable "frontend_image"   { type = string }
variable "backend_env"      { type = map(string); default = {} }
variable "frontend_env"     { type = map(string); default = {} }

# AWS-specific
variable "vpc_id"              { type = string; default = "" }
variable "public_subnet_ids"   { type = list(string); default = [] }
variable "private_subnet_ids"  { type = list(string); default = [] }
variable "ecs_tasks_sg_id"     { type = string; default = "" }
variable "aws_region"          { type = string; default = "eu-north-1" }

# GCP-specific
variable "gcp_project"         { type = string; default = "" }
variable "gcp_region"          { type = string; default = "europe-west3" }
variable "vpc_connector_id"    { type = string; default = "" }

locals {
  cmp_aws = var.cloud == "aws"
  cmp_gcp = var.cloud == "gcp"
  name    = "${var.project_name}-${var.environment}"
}

# ── AWS: ECS Cluster ───────────────────────────────────────────────────────────
resource "aws_ecs_cluster" "main" {
  count = local.cmp_aws ? 1 : 0
  name  = "${local.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# IAM role for ECS task execution (pull images, write logs)
data "aws_iam_policy_document" "ecs_assume" {
  count = local.cmp_aws ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_exec" {
  count              = local.cmp_aws ? 1 : 0
  name               = "${local.name}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume[0].json
}

resource "aws_iam_role_policy_attachment" "ecs_exec" {
  count      = local.cmp_aws ? 1 : 0
  role       = aws_iam_role.ecs_exec[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ── AWS: ECS Task Definitions ─────────────────────────────────────────────────
resource "aws_ecs_task_definition" "backend" {
  count = local.cmp_aws ? 1 : 0

  family                   = "${local.name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_exec[0].arn

  container_definitions = jsonencode([{
    name      = "backend"
    image     = var.backend_image
    essential = true
    portMappings = [{ containerPort = 3000 }]
    environment = [for k, v in var.backend_env : { name = k, value = v }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${local.name}/backend"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "frontend" {
  count = local.cmp_aws ? 1 : 0

  family                   = "${local.name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_exec[0].arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.frontend_image
    essential = true
    portMappings = [{ containerPort = 3000 }]
    environment = [for k, v in var.frontend_env : { name = k, value = v }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${local.name}/frontend"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# ── AWS: ECS Services ─────────────────────────────────────────────────────────
resource "aws_ecs_service" "backend" {
  count = local.cmp_aws ? 1 : 0

  name            = "${local.name}-backend"
  cluster         = aws_ecs_cluster.main[0].id
  task_definition = aws_ecs_task_definition.backend[0].arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_tasks_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend[0].arn
    container_name   = "backend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "frontend" {
  count = local.cmp_aws ? 1 : 0

  name            = "${local.name}-frontend"
  cluster         = aws_ecs_cluster.main[0].id
  task_definition = aws_ecs_task_definition.frontend[0].arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_tasks_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend[0].arn
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]
}

# ── AWS: Application Load Balancer ────────────────────────────────────────────
resource "aws_lb" "main" {
  count              = local.cmp_aws ? 1 : 0
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.ecs_tasks_sg_id]
  tags               = { Environment = var.environment }
}

resource "aws_lb_target_group" "backend" {
  count       = local.cmp_aws ? 1 : 0
  name        = "${local.name}-backend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/products"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }
}

resource "aws_lb_target_group" "frontend" {
  count       = local.cmp_aws ? 1 : 0
  name        = "${local.name}-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  count             = local.cmp_aws ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = 80
  protocol          = "HTTP"

  # Default: route to frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend[0].arn
  }
}

resource "aws_lb_listener_rule" "api" {
  count        = local.cmp_aws ? 1 : 0
  listener_arn = aws_lb_listener.http[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[0].arn
  }

  condition {
    path_pattern { values = ["/api/*"] }
  }
}

# ── GCP: Cloud Run services ────────────────────────────────────────────────────
resource "google_cloud_run_v2_service" "backend" {
  count    = local.cmp_gcp ? 1 : 0
  name     = "${local.name}-backend"
  location = var.gcp_region
  project  = var.gcp_project

  template {
    vpc_access {
      connector = var.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.backend_image

      dynamic "env" {
        for_each = var.backend_env
        content {
          name  = env.key
          value = env.value
        }
      }

      ports { container_port = 3000 }

      resources {
        limits = { cpu = "1", memory = "512Mi" }
      }
    }
  }
}

resource "google_cloud_run_v2_service" "frontend" {
  count    = local.cmp_gcp ? 1 : 0
  name     = "${local.name}-frontend"
  location = var.gcp_region
  project  = var.gcp_project

  template {
    vpc_access {
      connector = var.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.frontend_image

      dynamic "env" {
        for_each = var.frontend_env
        content {
          name  = env.key
          value = env.value
        }
      }

      ports { container_port = 3000 }

      resources {
        limits = { cpu = "1", memory = "512Mi" }
      }
    }
  }
}

# Allow unauthenticated invocations (public store)
resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  count    = local.cmp_gcp ? 1 : 0
  project  = var.gcp_project
  location = var.gcp_region
  name     = google_cloud_run_v2_service.backend[0].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "frontend_public" {
  count    = local.cmp_gcp ? 1 : 0
  project  = var.gcp_project
  location = var.gcp_region
  name     = google_cloud_run_v2_service.frontend[0].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "alb_dns_name" {
  description = "AWS ALB public DNS name (null on GCP)"
  value       = try(aws_lb.main[0].dns_name, null)
}

output "backend_cloud_run_url" {
  description = "GCP Cloud Run backend URL (null on AWS)"
  value       = try(google_cloud_run_v2_service.backend[0].uri, null)
}

output "frontend_cloud_run_url" {
  description = "GCP Cloud Run frontend URL (null on AWS)"
  value       = try(google_cloud_run_v2_service.frontend[0].uri, null)
}
