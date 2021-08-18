variable "region" {
  description = "The name of the AWS region you wish to deploy resources"
  default     = "us-east-2"
}
variable "namespace" {
  description = "Namespace for resource isolation, e.g. amazon"
  default     = "aws"
}
variable "env" {
  description = "Environment for the resources"
  default     = "dev"
}
variable "name" {
  description = "Deployment name"
  default     = "ecs-cluster"
}
variable "delimiter" {
  description = "delimiter, which could be used between name, namespace and env"
  default     = "-"
}
variable "tags" {
  description = "Additional tags for resources"
  default     = {}
}

variable "ami_name" {
  description = "Name filter for EC2 AMI lookup"
  default     = "amzn2-ami-ecs-hvm-2.0.????????-x86_64-ebs"
}

variable "instance_type" {
  description = "Type of EC2 instance to be launched"
  default     = "t3.micro"
}

variable "iam_instance_profile" {
  description = "Name of IAM instance profile associated with launched instances"
  default     = null
}