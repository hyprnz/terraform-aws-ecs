#-------------------------------------------------------------------------------
# ECS IAM ROLES AND POLICIES
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# ECS CONTAINER INSTANCE ROLE
# The ECS container instance role provides access to the ECS, ECS Tasks and EC2
# AWS services.
# The container instance role is responsible for creating clusters, starting
# tasks, retrieving containers from ECR and log generation.
#-------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_instance_role" {
  count              = var.single_cluster_account
  name               = "ecs_instance_role"
  assume_role_policy = file("${path.module}/policies/roles/ecs.json")
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  count  = var.single_cluster_account
  name   = "ecs_instance_role_policy"
  policy = file("${path.module}/policies/ecs-instance-role.json")
  role   = aws_iam_role.ecs_instance_role[0].id
}

resource "aws_iam_role_policy_attachment" "ecs_instance_s3" {
  count      = var.single_cluster_account
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_cloudwatch_logs" {
  count      = var.single_cluster_account
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs[0].arn
}

#-------------------------------------------------------------------------------
# ECS SERVICE SCHEDULER ROLE
# The ECS service scheduler role provides access to the ECS, ECS Tasks and EC2
# AWS services.
# The service scheduler is able to responsible for registering EC2  instances
# with the ALB.
#-------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_service_role" {
  count              = var.single_cluster_account
  name               = "ecs_service_role"
  assume_role_policy = file("${path.module}/policies/roles/ecs.json")
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  count  = var.single_cluster_account
  name   = "ecs_service_role_policy"
  policy = file("${path.module}/policies/ecs-service-role.json")
  role   = aws_iam_role.ecs_service_role[0].id
}

#-------------------------------------------------------------------------------
# ECS INSTANCE PROFILE
# The ECS instance profile enables EC2 instances to use the ECS Container
# Instance role by including this profile during configuration.
# ------------------------------------------------------------------------------
resource "aws_iam_instance_profile" "ecs" {
  count = var.single_cluster_account
  name  = "ecs_instance_profile"
  path  = "/"
  role  = aws_iam_role.ecs_instance_role[0].name

  lifecycle {
    create_before_destroy = true
  }
}

#-------------------------------------------------------------------------------
# ECS CLOUDWATCH LOGS POLICY
# Used by ECS Container Instance to create and access log groups and streams.
#-------------------------------------------------------------------------------
resource "aws_iam_policy" "ecs_cloudwatch_logs" {
  count       = var.single_cluster_account
  name        = "ecs_cloudwatch_logs"
  description = "ECS CloudWatch Logs Policy"
  policy      = file("${path.module}/policies/ecs-cloudwatch-logs.json")
}

