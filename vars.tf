# TOGGLES
#--------
variable "single_cluster_account" {
  description = "Whether this account contains a single ECS Cluster"
  default     = true
}

variable "create_worker_cluster" {
  description = "Whether to create a Worker Cluster"
  default     = true
}

#-------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
#-------------------------------------------------------------------------------
variable "cluster_name" {
  description = "The name of the ECS Cluster"
}

variable "env" {
  description = "Short version of the environment name used in lookup"
}

variable "vpc_id" {
  description = "VPC to place the ECS Cluster resource into"
}

variable "iam_key_pair_name" {
}

variable "iam_instance_profile_name" {
  default = "ecs_instance_profile"
}

#-------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
#-------------------------------------------------------------------------------
variable "use_efs_volumes" {
  description = "Should the Cluster use/create EFS volumes for use with containers"
  type        = number
  default     = 0
}

variable "kafka_root_block_device_volume_size" {
  description = "Kafka root disk size"
  default     = 40
}

variable "workers_spotfleet" {
  description = "Should the worker instances utilise Spot Fleet"
  type        = number
  default     = 0
}

# Only need to set this if using Workers Spot Fleet
variable "workers_max_spotprice" {
  description = "Workers maximum spot price"
  default     = "0.00"
}

variable "key_name" {
  description = "AWS SSH Key name"
  default     = "devops_ecs"
}

variable "key_file" {
  description = "AWS SSH Public Key file"
  default     = "~/.ssh/devops_ecs.pub"
}

#------------------------------------------------------------------------------
# This should be defaulted to true when Kafka is present in all environments!
#------------------------------------------------------------------------------
variable "create_kafka_cluster" {
  description = "Determine if a Kafka cluster should exist in an environment"
  default     = false
}

variable "asg_min_size" {
  description = "Minimum number of instances to run in the autoscaling group"
  default     = "3"
}

variable "asg_max_size" {
  description = "Maximum number of instances to run in the autoscaling group"
  default     = "6"
}

variable "asg_desired_capacity" {
  description = "Desired number of instances to run in the autoscaling group"
  default     = "3"
}

variable "asg_kafka_min_size" {
  description = "Minimum number of instances to run in the autoscaling group"
  default     = "3"
}

variable "asg_kafka_max_size" {
  description = "Maximum number of instances to run in the autoscaling group"
  default     = "3"
}

variable "asg_kafka_desired_capacity" {
  description = "Desired number of instances to run in the autoscaling group"
  default     = "3"
}

variable "availability_zones" {
  description = "Availability zones to be used by the autoscaling group"
  type        = list(string)

  default = [
    "ap-southeast-2a",
    "ap-southeast-2b",
    "ap-southeast-2c",
  ]
}

variable "workers_spot_instance_type" {
  description = "AWS Instance Type used by Worker Spot Instances"
  default     = "t2.medium"
}

variable "instance_type" {
  description = "AWS Instance Type used in the Launch Configuration"
  default     = "t2.medium"
}

variable "kafka_instance_type" {
  description = "AWS Instance Type used in the Kafka Launch Configuration"
  default     = "m4.2xlarge"
}

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. ap-southeast-2)"
  default     = "ap-southeast-2"
}

#-------------------------------------------------------------------------------
# MAP LOOKUPS
#-------------------------------------------------------------------------------
variable "environment" {
  description = "Full environment name"
}

variable "data_template" {
  description = "Lookup for Data Templates based on use_efs_volumes"
  type        = map(string)

  default = {
    "1" = "ecs-efs-instance-user-data.tpl"
    "0" = "ecs-instance-user-data.tpl"
  }
}

