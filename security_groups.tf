/**
 * Provides internal access to container ports
 */

resource "aws_security_group" "ecs" {
  name        = "${var.env == "prod" ? "ecs-sg" : join("-",list("ecs-sg", var.env))}"
  description = "Container Instance Allowed Ports"
  vpc_id      = "${data.aws_vpc.ecs.id}"

  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.env == "prod" ? "ecs-sg" : join("-",list("ecs-sg", var.env))}"
  }
}

/**
 * Provides RDS access to the containers in ECS
 */

resource "aws_security_group" "ecs_rds" {
  name        = "${var.env == "prod" ? "rds-ecs" : join("-",list("rds-ecs", var.env))}"
  description = "RDS Port ingress from ECS SG"
  vpc_id      = "${data.aws_vpc.ecs.id}"

  tags {
    Name = "${var.env == "prod" ? "rds-ecs" : join("-",list("rds-ecs", var.env))}"
  }
}

resource "aws_security_group_rule" "ecs_rds_cluster_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.ecs.id}"
  security_group_id        = "${aws_security_group.ecs_rds.id}"
}

resource "aws_security_group_rule" "ecs_rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ecs_rds.id}"
}

/**
 * Provide EFS access to the containers in ECS
 */

resource "aws_security_group" "ecs_efs" {
  name        = "${var.env == "prod" ? "ecs-efs" : join("-",list("ecs-efs", var.env))}"
  count       = "${var.use_efs_volumes}"
  description = "EFS Security Group for ECS Container Use"
  vpc_id      = "${data.aws_vpc.ecs.id}"

  tags {
    Name = "${var.env == "prod" ? "ecs-efs" : join("-",list("ecs-efs", var.env))}"
  }
}

resource "aws_security_group_rule" "ecs_efs_cluster_ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  count                    = "${var.use_efs_volumes}"
  source_security_group_id = "${aws_security_group.ecs.id}"
  security_group_id        = "${aws_security_group.ecs_efs.id}"
}

resource "aws_security_group_rule" "ecs_efs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  count             = "${var.use_efs_volumes}"
  security_group_id = "${aws_security_group.ecs_efs.id}"
}

/**
 * Provides HTTPS access to the ALB
 */

resource "aws_security_group" "allow_https" {
  name        = "${var.env == "prod" ? "ecs_allow_https" : join("-",list("ecs_allow_https", var.env))}"
  description = "ECS Allow https traffic"
  vpc_id      = "${data.aws_vpc.ecs.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.env == "prod" ? "ecs_allow_https" : join("-",list("ecs_allow_https", var.env))}"
  }
}
