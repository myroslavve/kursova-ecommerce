# =============================================================================
# modules/network — AWS resources
# Created only when var.cloud == "aws"
# =============================================================================

locals {
  aws = var.cloud == "aws"
  name = "${var.project_name}-${var.environment}"
}

# ── VPC ───────────────────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  count = local.aws ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${local.name}-vpc" }
}

# ── Internet Gateway ──────────────────────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  count  = local.aws ? 1 : 0
  vpc_id = aws_vpc.main[0].id
  tags   = { Name = "${local.name}-igw" }
}

# ── Public subnets ────────────────────────────────────────────────────────────
data "aws_availability_zones" "available" {
  count = local.aws ? 1 : 0
  state = "available"
}

resource "aws_subnet" "public" {
  count = local.aws ? length(var.public_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available[0].names[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${local.name}-public-${count.index + 1}" }
}

# ── NAT Gateway (one, in first public subnet) ─────────────────────────────────
resource "aws_eip" "nat" {
  count  = local.aws ? 1 : 0
  domain = "vpc"
  tags   = { Name = "${local.name}-nat-eip" }
}

resource "aws_nat_gateway" "main" {
  count         = local.aws ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${local.name}-nat" }
  depends_on    = [aws_internet_gateway.main]
}

# ── Private subnets ───────────────────────────────────────────────────────────
resource "aws_subnet" "private" {
  count = local.aws ? length(var.private_subnet_cidrs) : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available[0].names[count.index]

  tags = { Name = "${local.name}-private-${count.index + 1}" }
}

# ── Route tables ──────────────────────────────────────────────────────────────
resource "aws_route_table" "public" {
  count  = local.aws ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
  tags = { Name = "${local.name}-rt-public" }
}

resource "aws_route_table_association" "public" {
  count          = local.aws ? length(aws_subnet.public) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = local.aws ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }
  tags = { Name = "${local.name}-rt-private" }
}

resource "aws_route_table_association" "private" {
  count          = local.aws ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# ── Security Group: ECS tasks (backend + frontend) ────────────────────────────
resource "aws_security_group" "ecs_tasks" {
  count  = local.aws ? 1 : 0
  name   = "${local.name}-ecs-tasks-sg"
  vpc_id = aws_vpc.main[0].id

  ingress {
    description = "HTTP from anywhere (ALB forwards here)"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.name}-ecs-tasks-sg" }
}

# ── Security Group: RDS ───────────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  count  = local.aws ? 1 : 0
  name   = "${local.name}-rds-sg"
  vpc_id = aws_vpc.main[0].id

  ingress {
    description     = "PostgreSQL from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks[0].id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.name}-rds-sg" }
}
