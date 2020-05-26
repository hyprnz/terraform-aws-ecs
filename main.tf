terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

#-------------------------------------------------------------------------------
# ECS CLUSTER
#-------------------------------------------------------------------------------
resource "aws_ecs_cluster" "ecs" {
  name = var.cluster_name
}

#-------------------------------------------------------------------------------
# ECS CLUSTER S3 CONFIGURATION BUCKET
# S3 bucket that holds the ECS Cluster configuration
#-------------------------------------------------------------------------------
resource "aws_s3_bucket" "ecs_config" {
  bucket        = "ecs-config-${var.env}"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name        = "ECS Configuration ${var.env}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_object" "ecs_config" {
  bucket  = aws_s3_bucket.ecs_config.bucket
  key     = "ecs.config"
  content = data.template_file.ecs_config.rendered

  depends_on = [aws_s3_bucket.ecs_config]
}

#-------------------------------------------------------------------------------
# ECS EC2 LAUNCH CONFIGURATION
#-------------------------------------------------------------------------------
resource "aws_launch_configuration" "ecs" {
  #count                = "${1 - var.workers_spotfleet}"
  count         = false == var.workers_spotfleet && var.create_worker_cluster ? 1 : 0
  name_prefix   = "ECS-${var.cluster_name}-"
  image_id      = data.aws_ami.ecs_optimized_ami.id
  instance_type = var.instance_type

  # Note splat syntax fix in 0.12
  # https://github.com/hashicorp/terraform/issues/11574
  iam_instance_profile = var.single_cluster_account ? join("", aws_iam_instance_profile.ecs.*.name) : var.iam_instance_profile_name

  # key_name        = var.single_cluster_account ? join("", aws_key_pair.ecs.*.key_name) : var.iam_key_pair_name
  security_groups = [aws_security_group.ecs.id]
  user_data       = data.template_file.ecs_instance_user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

#-------------------------------------------------------------------------------
# ECS KAFKA EC2 LAUNCH CONFIGURATION
#-------------------------------------------------------------------------------
resource "aws_launch_configuration" "ecs_kafka" {
  count         = var.create_kafka_cluster
  name_prefix   = "ECS-Kafka-${var.cluster_name}-"
  image_id      = data.aws_ami.ecs_optimized_ami.id
  instance_type = var.kafka_instance_type

  # Note splat syntax fix in 0.12
  # https://github.com/hashicorp/terraform/issues/11574
  iam_instance_profile = var.single_cluster_account ? join("", aws_iam_instance_profile.ecs.*.name) : var.iam_instance_profile_name

  root_block_device {
    volume_size = var.kafka_root_block_device_volume_size
  }

  # See Note above about splat syntax
  key_name        = var.single_cluster_account ? join("", aws_key_pair.ecs.*.key_name) : var.iam_key_pair_name
  security_groups = [aws_security_group.ecs.id]
  user_data       = data.template_file.kafka_ecs_instance_user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

#-------------------------------------------------------------------------------
# ECS EC2 AUTOSCALING GROUP 
#-------------------------------------------------------------------------------
resource "aws_autoscaling_group" "ecs" {
  count                = false == var.workers_spotfleet && var.create_worker_cluster ? 1 : 0
  name                 = var.env == "prod" ? "ecs-asg" : "ecs-asg-${var.env}"
  launch_configuration = aws_launch_configuration.ecs[0].name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ECS-${var.cluster_name}"
    propagate_at_launch = true
  }

  # Used by datadog agent to infer the environment name.
  tag {
    key                 = "env"
    value               = var.env
    propagate_at_launch = true
  }

  depends_on = [aws_s3_bucket.ecs_config]
}

#-------------------------------------------------------------------------------
# ECS KAFKA EC2 AUTOSCALING GROUP
#-------------------------------------------------------------------------------
resource "aws_autoscaling_group" "ecs_kafka" {
  count                = var.create_kafka_cluster
  name                 = var.env == "prod" ? "ecs-kafka-asg" : "ecs-kafka-asg-${var.env}"
  launch_configuration = aws_launch_configuration.ecs_kafka[0].name
  vpc_zone_identifier  = data.aws_subnet_ids.kafka.ids
  min_size             = var.asg_kafka_min_size
  max_size             = var.asg_kafka_max_size
  desired_capacity     = var.asg_kafka_desired_capacity

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ECS-Kafka-${var.cluster_name}"
    propagate_at_launch = true
  }

  # Used by datadog agent to infer the environment name.
  tag {
    key                 = "env"
    value               = var.env
    propagate_at_launch = true
  }

  depends_on = [aws_s3_bucket.ecs_config]
}

