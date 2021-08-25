output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster created"
  value       = module.ecs_cluster.ecs_cluster_arn
}

output "ecs_loggroup_arn" {
  description = "The ARN of the Cloudwatch LogGroup created"
  value       = module.ecs_cluster.ecs_cloudwatch_group_arn
}
