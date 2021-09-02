output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.arn
}

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "kms_arn" {
  description = "The ARN of the KMS key created for use with ECS cluster related resources"
  value       = aws_kms_key.kmskey.arn
}

output "kms_id" {
  description = "The ID of the KMS key created for use with ECS cluster related resources"
  value       = aws_kms_key.kmskey.key_id
}

output "ecs_cloudwatch_group_arn" {
  description = "The ARN of the Cloudwatch LogGroup created for use with ECS cluster"
  value       = aws_cloudwatch_log_group.ecs_cluster_log_group.arn
}

output "ecs_capacity_provider_arn" {
  description = "The ARN of the ECS cluster's capacity provider"
  value       = aws_ecs_capacity_provider.capacity_provider.arn
}

output "ecs_capacity_provider_id" {
  description = "The ID of the ECS cluster's capacity provider"
  value       = aws_ecs_capacity_provider.capacity_provider.id
}
