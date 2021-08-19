terraform {
  required_version = ">= 1.0.0"
  backend "remote" {}
}

######################################
# Defaults
######################################

provider "aws" {
  region = var.region
}

resource "random_string" "rand4" {
  length  = 4
  special = false
  upper   = false
}

######################################
# Generate Tags
######################################

module "vpc_label" {
  source    = "aws-ia/label/aws"
  version   = "0.0.2"
  region    = var.region
  namespace = var.namespace
  env       = var.env
  name      = "${var.name}-${random_string.rand4.result}"
  delimiter = var.delimiter
  tags      = merge(var.tags, tomap({ propogate_at_launch = "true", "terraform" = "true" }))
}

######################################
# Create VPC
######################################

module "ecs_vpc" {
  source               = "aws-ia/vpc/aws"
  version              = "0.0.3"
  name                 = "ecs-vpc"
  region               = var.region
  cidr                 = "10.0.0.0/16"
  public_subnets       = ["10.0.0.0/20"]
  private_subnets_A    = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
  enable_dns_hostnames = true
  tags                 = module.vpc_label.tags
  create_vpc           = true
}

######################################
# Create Security Group
######################################

resource "aws_security_group" "ecs_security_group" {
  name_prefix = "${var.name}-sg-"
  description = "Security Group for ECS Cluster"
  vpc_id      = module.ecs_vpc.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ecs_security_group_ingress" {
  description       = "Allow inbound TCP for the cluster"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [module.ecs_vpc.vpc_cidr]
  security_group_id = aws_security_group.ecs_security_group.id
}

resource "aws_security_group_rule" "ecs_security_group_egress" {
  description       = "Allow outbound HTTPS for the cluster"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007 ignore warning as this open outbound security rule is valid
  security_group_id = aws_security_group.ecs_security_group.id
}

######################################
# Create IAM Instance Profile
######################################

resource "aws_iam_policy" "instance_policy" {
  name   = "${var.name}-ecs-instance"
  path   = "/"
  policy = data.aws_iam_policy_document.instance_policy.json
}

resource "aws_iam_role" "instance" {
  name = "${var.name}-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "instance_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.instance.name
}

######################################
# Create Launch template
######################################

resource "aws_launch_template" "ecs_launch_template" {
  name_prefix = "${var.name}-template-"
  image_id    = var.image_id != "" ? var.image_id : data.aws_ami.ecs.id

  instance_type = var.instance_type
  user_data     = base64encode(data.template_file.ecs_optimized.rendered)
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_security_group.id]
  }

  vpc_security_group_ids = []

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, tomap({
      Name = var.name
    }))
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

######################################
# Create ECS Cluster
######################################

module "ecs_cluster" {
  source             = "../"
  region             = var.region
  name               = var.name
  launch_template_id = aws_launch_template.ecs_launch_template.id
  asg_max_size       = 5
  vpc_subnet_ids     = [module.ecs_vpc.PrivateSubnet1AID, module.ecs_vpc.PrivateSubnet2AID, module.ecs_vpc.PrivateSubnet3AID]
}
