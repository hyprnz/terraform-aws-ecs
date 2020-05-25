#-------------------------------------------------------------------------------
# ECS CLUSTER ATTRIBUTES
#-------------------------------------------------------------------------------
output "cluster_name" {
  value = aws_ecs_cluster.ecs.name
}

output "cluster_id" {
  value = aws_ecs_cluster.ecs.id
}

output "single_cluster_account" {
  value = var.single_cluster_account == true ? "Single cluster account" : "Multi cluster account"
}

output "create_worker_cluster" {
  value = var.create_worker_cluster == true ? "Worker cluster created" : "Worker cluster not created"
}

#-------------------------------------------------------------------------------
# ECS CLUSTER S3 CONFIGURATION BUCKET ATTRIBUTES
#-------------------------------------------------------------------------------
output "ecs_config_bucket_id" {
  value = aws_s3_bucket.ecs_config.id
}

output "ecs_config_bucket_arn" {
  value = aws_s3_bucket.ecs_config.arn
}

output "ecs_config_bucket_bucket_domain_name" {
  value = aws_s3_bucket.ecs_config.bucket_domain_name
}

output "ecs_config_bucket_hosted_zone_id" {
  value = aws_s3_bucket.ecs_config.hosted_zone_id
}

output "ecs_config_bucket_region" {
  value = aws_s3_bucket.ecs_config.region
}

output "ecs_config.id" {
  value = aws_s3_bucket_object.ecs_config.id
}

output "ecs_config.etag" {
  value = aws_s3_bucket_object.ecs_config.etag
}

output "ecs_config.version_id" {
  value = aws_s3_bucket_object.ecs_config.version_id
}

#-------------------------------------------------------------------------------
# ECS EC2 LAUNCH CONFIGURATION ATTRIBUTES
#-------------------------------------------------------------------------------
output "launch_configuration_id" {
  value = aws_launch_configuration.ecs.*.id
}

output "launch_configuration_name" {
  value = aws_launch_configuration.ecs.*.name
}

#-------------------------------------------------------------------------------
# ECS KAFKA EC2 LAUNCH CONFIGURATION ATTRIBUTES
#-------------------------------------------------------------------------------
output "kafka_launch_configuration_id" {
  value = element(concat(aws_launch_configuration.ecs_kafka.*.id, [""]), 0)
}

output "kafka_launch_configuration_name" {
  value = element(concat(aws_launch_configuration.ecs_kafka.*.name, [""]), 0)
}

#-------------------------------------------------------------------------------
# ECS EC2 AUTOSCALING GROUP ATTRIBUTES
#-------------------------------------------------------------------------------
output "aws_autoscaling_group_id" {
  value = aws_autoscaling_group.ecs.*.id
}

output "aws_autoscaling_group_arn" {
  value = aws_autoscaling_group.ecs.*.arn
}

#output "aws_autoscaling_group_availability_zones" {
#  value = "${aws_autoscaling_group.ecs.*.availability_zones}"
#}

output "aws_autoscaling_group_min_size" {
  value = aws_autoscaling_group.ecs.*.min_size
}

output "aws_autoscaling_group_max_size" {
  value = "aws_autoscaling_group.ecs.*.max_size"
}

output "aws_autoscaling_group_default_cooldown" {
  value = aws_autoscaling_group.ecs.*.default_cooldown
}

output "aws_autoscaling_group_name" {
  value = aws_autoscaling_group.ecs.*.name
}

output "aws_autoscaling_group_health_check_grace_period" {
  value = aws_autoscaling_group.ecs.*.health_check_grace_period
}

output "aws_autoscaling_group_health_check_type" {
  value = aws_autoscaling_group.ecs.*.health_check_type
}

output "aws_autoscaling_group_desired_capacity" {
  value = aws_autoscaling_group.ecs.*.desired_capacity
}

output "aws_autoscaling_group_launch_configuration" {
  value = aws_autoscaling_group.ecs.*.launch_configuration
}

output "aws_autoscaling_group_vpc_zone_identifier" {
  value = aws_autoscaling_group.ecs.*.vpc_zone_identifier
}

output "aws_autoscaling_group_load_balancers" {
  value = aws_autoscaling_group.ecs.*.load_balancers
}

output "aws_autoscaling_group_target_group_arns" {
  value = aws_autoscaling_group.ecs.*.target_group_arns
}

#-------------------------------------------------------------------------------
# ECS KAFKA EC2 AUTOSCALING GROUP ATTRIBUTES
#-------------------------------------------------------------------------------
output "kafka_aws_autoscaling_group_id" {
  value = element(concat(aws_autoscaling_group.ecs_kafka.*.id, [""]), 0)
}

output "kafka_aws_autoscaling_group_arn" {
  value = element(concat(aws_autoscaling_group.ecs_kafka.*.arn, [""]), 0)
}

output "kafka_aws_autoscaling_group_min_size" {
  value = element(concat(aws_autoscaling_group.ecs_kafka.*.min_size, [""]), 0)
}

output "kafka_aws_autoscaling_group_max_size" {
  value = element(concat(aws_autoscaling_group.ecs_kafka.*.max_size, [""]), 0)
}

output "kafka_aws_autoscaling_group_default_cooldown" {
  value = element(
    concat(aws_autoscaling_group.ecs_kafka.*.default_cooldown, [""]),
    0,
  )
}

output "kafka_aws_autoscaling_group_name" {
  value = element(concat(aws_autoscaling_group.ecs_kafka.*.name, [""]), 0)
}

output "kakfa_aws_autoscaling_group_health_check_grace_period" {
  value = element(
    concat(
      aws_autoscaling_group.ecs_kafka.*.health_check_grace_period,
      [""],
    ),
    0,
  )
}

output "kakfa_aws_autoscaling_group_health_check_type" {
  value = element(
    concat(aws_autoscaling_group.ecs_kafka.*.health_check_type, [""]),
    0,
  )
}

output "kafka_aws_autoscaling_group_desired_capacity" {
  value = element(
    concat(aws_autoscaling_group.ecs_kafka.*.desired_capacity, [""]),
    0,
  )
}

output "kafka_aws_autoscaling_group_launch_configuration" {
  value = element(
    concat(aws_autoscaling_group.ecs_kafka.*.launch_configuration, [""]),
    0,
  )
}

output "kafka_aws_autoscaling_group_vpc_zone_identifier" {
  value = aws_autoscaling_group.ecs_kafka.*.vpc_zone_identifier
}

output "kafka_aws_autoscaling_group_load_balancers" {
  value = aws_autoscaling_group.ecs_kafka.*.load_balancers
}

output "kafka_aws_autoscaling_group_target_group_arns" {
  value = aws_autoscaling_group.ecs_kafka.*.target_group_arns
}

#-------------------------------------------------------------------------------
# ECS EFS VOLUME FILE SYSTEM ATTRIBUTES
#-------------------------------------------------------------------------------
output "aws_ecs_efs_file_system_id" {
  value = element(concat(aws_efs_file_system.ecs_volumes.*.id, [""]), 0)
}

#-------------------------------------------------------------------------------
# ECS EFS MOUNT TARGET ATTRIBUTES
#-------------------------------------------------------------------------------
output "aws_ecs_efs_mount_target_ids" {
  value = aws_efs_mount_target.ecs_volumes.*.id
}

output "aws_ecs_efs_mount_target_dns_name" {
  value = aws_efs_mount_target.ecs_volumes.*.dns_name
}

output "aws_ecs_efs_mount_target_network_interface_ids" {
  value = aws_efs_mount_target.ecs_volumes.*.network_interface_id
}

#------------------------------------------------------------------------------
# ECS CLUSTER WORKER SPOTFLEET ATTRIBUTES
#------------------------------------------------------------------------------
output "aws_spotfleet_request_ecs_workers_id" {
  value = aws_spot_fleet_request.ecs_workers.*.id
}

output "aws_spotfleet_request_ecs_workers_request_state" {
  value = aws_spot_fleet_request.ecs_workers.*.spot_request_state
}

