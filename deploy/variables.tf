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

variable "image_id" {
  description = "AMI image_id for ECS instance"
  default     = ""
}

variable "instance_type" {
  description = "Type of EC2 instance to be launched"
  default     = "t3.micro"
}

variable "create_service_role" {
  description = "Variable to decide whether IAM Service linked role should be created for ECS"
  default     = false
  type        = bool
}

