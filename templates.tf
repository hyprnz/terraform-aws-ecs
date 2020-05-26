#-------------------------------------------------------------------------------
# ECS CONFIGURATION TEMPLATE
#-------------------------------------------------------------------------------
/* ECS Config Template */
data "template_file" "ecs_config" {
  template = file("${path.module}/templates/ecs-config.tpl")

  vars = {
    ecs_cluster_name = var.cluster_name
  }
}

#-------------------------------------------------------------------------------
# ECS INSTANCE USER DATA TEMPLATE
# Picks the data template to use based on the value of the use_efs_volumes
# variable. See the vars.tf file for the map based on this boolean value.
#-------------------------------------------------------------------------------
data "template_file" "ecs_instance_user_data" {
  template = file(
    "${path.module}/templates/${var.data_template[var.use_efs_volumes]}",
  )

  vars = {
    efs_file_system_name = "efs-${var.env}"
    s3_bucket_name       = "ecs-config-${var.env}-${data.aws_caller_identity.current.account_id}"
    stack                = "ECS-${var.cluster_name}"
  }
}

data "template_file" "ecs_spot_instance_user_data" {
  template = file("${path.module}/templates/ecs-spot-instance-user-data.tpl")

  vars = {
    efs_file_system_name = "efs-${var.env}"
    s3_bucket_name       = "ecs-config-${var.env}-${data.aws_caller_identity.current.account_id}"
    stack                = "ECS-${var.cluster_name}"
  }
}

data "template_file" "kafka_ecs_instance_user_data" {
  template = file(
    "${path.module}/templates/${var.data_template[var.use_efs_volumes]}",
  )

  vars = {
    efs_file_system_name = "efs-${var.env}"
    s3_bucket_name       = "ecs-config-${var.env}-${data.aws_caller_identity.current.account_id}"
    stack                = "ECS-Kafka-${var.cluster_name}"
  }
}

