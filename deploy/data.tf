data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "template_file" "ecs_optimized" {
  template = <<EOF
#!/bin/bash
echo 'ECS_CLUSTER=$${ClusterName}' >> /etc/ecs/ecs.config
yum upgrade -y
yum install -y awscli
EOF
  vars = {
    ClusterName = var.name
  }
}

data "aws_iam_policy_document" "instance_policy" {
  statement {
    sid = "CloudwatchPutMetricData"

    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "InstanceLogging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      format(
        "arn:aws:logs:%s:%s:log-group:%s-loggroup",
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id,
        var.name
      )
    ]
  }

  statement {
    sid    = "ECSAccessPolicy"
    effect = "Allow"

    actions = [
      "ec2:DescribeTags",
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:SubmitContainerStateChange",
      "ecs:SubmitTaskStateChange",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      format(
        "arn:%s:logs:%s:%s:log-group:%s-loggroup",
        data.aws_partition.current.partition,
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id,
        var.name
      ),
      format(
        "arn:%s:ecs:%s:%s:cluster/*",
        data.aws_partition.current.partition,
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id
      )
    ]
  }
}
