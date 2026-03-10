output "vpc_id" {
  description = "AWS VPC ID (null on GCP)"
  value       = try(aws_vpc.main[0].id, null)
}

output "public_subnet_ids" {
  description = "AWS public subnet IDs (null on GCP)"
  value       = try(aws_subnet.public[*].id, null)
}

output "private_subnet_ids" {
  description = "AWS private subnet IDs (null on GCP)"
  value       = try(aws_subnet.private[*].id, null)
}

output "ecs_tasks_sg_id" {
  description = "AWS Security Group ID for ECS tasks (null on GCP)"
  value       = try(aws_security_group.ecs_tasks[0].id, null)
}

output "rds_sg_id" {
  description = "AWS Security Group ID for RDS (null on GCP)"
  value       = try(aws_security_group.rds[0].id, null)
}

output "vpc_connector_id" {
  description = "GCP Serverless VPC Access Connector ID (null on AWS)"
  value       = try(google_vpc_access_connector.connector[0].id, null)
}
