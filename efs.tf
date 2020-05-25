#-------------------------------------------------------------------------------
# ECS EFS VOLUME FILE SYSTEM
# Will create an EFS file system only when variable use_efs_volumes is set to
# true.
#-------------------------------------------------------------------------------
resource "aws_efs_file_system" "ecs_volumes" {
  count          = "${var.use_efs_volumes}"
  creation_token = "efs-${var.env}"

  tags {
    Name = "efs-${var.env}"
  }
}

#-------------------------------------------------------------------------------
# ECS EFS VOLUMES MOUNT TARGETS
# This will create 3 mount targets if variable use_efs_volumes is set to true
# otherwise the value of count will be 0 and no mount targets will be created.
#-------------------------------------------------------------------------------
resource "aws_efs_mount_target" "ecs_volumes" {
  count           = "${var.use_efs_volumes ? 3 : 0}"
  file_system_id  = "${aws_efs_file_system.ecs_volumes.id}"
  subnet_id       = "${element(sort(data.aws_subnet_ids.private.ids), count.index)}"
  security_groups = ["${aws_security_group.ecs_efs.id}"]
}
