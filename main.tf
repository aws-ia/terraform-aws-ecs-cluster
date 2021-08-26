provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.0.0"
}

resource "aws_kms_key" "kmskey" {
  description             = "KMS key for ${var.name} cluster"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudwatch.json
  tags                    = var.tags
}

resource "aws_cloudwatch_log_group" "ecs_cluster_log_group" {
  name              = "${var.name}-loggroup"
  kms_key_id        = aws_kms_key.kmskey.arn
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name               = var.name
  tags               = var.tags
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.kmskey.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_cluster_log_group.name
      }
    }
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "capacity-provider-${var.name}"
  tags = var.tags

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.capacity_provider_asg.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      maximum_scaling_step_size = 1
    }
  }
}

resource "aws_autoscaling_group" "capacity_provider_asg" {
  name_prefix          = "${var.name}-"
  vpc_zone_identifier  = var.vpc_subnet_ids
  max_size             = var.asg_max_size
  min_size             = 0
  desired_capacity     = 1
  capacity_rebalance   = true
  launch_configuration = var.launch_configuration

  dynamic "launch_template" {
    for_each = var.launch_template_id == null ? [] : [var.launch_template_id]

    content {
      id      = var.launch_template_id
      version = "$Latest"
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
