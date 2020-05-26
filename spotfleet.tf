#------------------------------------------------------------------------------
# SPOT FLEET GLOBAL IAM ROLE
#------------------------------------------------------------------------------
data "aws_iam_role" "fleet_role" {
  count = var.workers_spotfleet
  name  = "spot_fleet_role"
}

resource "aws_spot_fleet_request" "ecs_workers" {
  count                               = var.workers_spotfleet
  iam_fleet_role                      = data.aws_iam_role.fleet_role[0].arn
  spot_price                          = var.workers_max_spotprice
  target_capacity                     = "4"
  allocation_strategy                 = "diversified"
  wait_for_fulfillment                = true
  terminate_instances_with_expiration = false
  valid_until                         = timeadd(timestamp(), "1440h")

  launch_specification {
    ami                    = data.aws_ami.ecs_optimized_ami.id
    instance_type          = var.workers_spot_instance_type
    spot_price             = var.workers_max_spotprice
    subnet_id              = element(tolist(data.aws_subnet_ids.private.ids), 0)
    vpc_security_group_ids = [aws_security_group.ecs.id]
    iam_instance_profile   = var.iam_instance_profile_name
    # key_name               = var.iam_key_pair_name
    user_data              = data.template_file.ecs_spot_instance_user_data.rendered
    monitoring             = true

    tags = {
      Name = "ECS-${var.cluster_name}"
      env  = var.env
    }
  }

  launch_specification {
    ami                    = data.aws_ami.ecs_optimized_ami.id
    instance_type          = var.workers_spot_instance_type
    spot_price             = var.workers_max_spotprice
    subnet_id              = element(tolist(data.aws_subnet_ids.private.ids), 1)
    vpc_security_group_ids = [aws_security_group.ecs.id]
    iam_instance_profile   = var.iam_instance_profile_name
    # key_name               = var.iam_key_pair_name
    user_data              = data.template_file.ecs_spot_instance_user_data.rendered
    monitoring             = true

    tags = {
      Name = "ECS-${var.cluster_name}"
      env  = var.env
    }
  }

  launch_specification {
    ami                    = data.aws_ami.ecs_optimized_ami.id
    instance_type          = var.workers_spot_instance_type
    spot_price             = var.workers_max_spotprice
    subnet_id              = element(tolist(data.aws_subnet_ids.private.ids), 2)
    vpc_security_group_ids = [aws_security_group.ecs.id]
    iam_instance_profile   = var.iam_instance_profile_name
    # key_name               = var.iam_key_pair_name
    user_data              = data.template_file.ecs_spot_instance_user_data.rendered
    monitoring             = true

    tags = {
      Name = "ECS-${var.cluster_name}"
      env  = var.env
    }
  }

  lifecycle {
    ignore_changes        = [valid_until]
    create_before_destroy = true
  }

  depends_on = [aws_s3_bucket.ecs_config]
}

