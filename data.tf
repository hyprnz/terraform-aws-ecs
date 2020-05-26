# -----------------------------------------------------------------------------
# TERRAFORM REMOTE STATE
# This repository needs remote state related to IAM and VPC.
# The IAM state is used to retrieve the ECS Container Instance Profile Name.
# The VPC state is used to gather security group information for use in
# launch configurations.
# -----------------------------------------------------------------------------
data "aws_vpc" "ecs" {
  id = var.vpc_id
}

#------------------------------------------------------------------------------
# SUBNET IDS
# - used by the autoscaling group vpc_zone_identifier
#------------------------------------------------------------------------------

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.ecs.id

  //tags = {
  //  Tier        = "Private"
  //  M5Available = "True"
  //}
}

data "aws_subnet_ids" "kafka" {
  vpc_id = data.aws_vpc.ecs.id

  //tags = {
  //  Tier = "Private"
  //}
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.ecs.id

  //tags = {
  //  Tier = "Private"
  //}
}

# ----------------------------------------------------------------------------
# ECS AMI
# ----------------------------------------------------------------------------
data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.????????-x86_64-ebs"]
  }
}

data "aws_caller_identity" "current" {}