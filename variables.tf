variable "region" {
  type        = string
  description = "the name of the region you wish to deploy into"
  default     = "us-east-1"
}

variable "name" {
  description = "Name given resources"
  type        = string
  default     = "aws-ia-ecs"
}

variable "launch_template_id" {
  type        = string
  description = "ID of the launch template for use by AutoScalingGroup to create new instances"
  default     = null
}

variable "launch_configuration" {
  type        = string
  description = "Name of the launch configuration for use by AutoScalingGroup to create new instances"
  default     = null
}

variable "asg_max_size" {
  description = "Maximum allowed nodes in the cluster"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default = {
    ModuleName = "terraform-ecs-cluster"
  }
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnets to put instances in"
  default     = []
}
