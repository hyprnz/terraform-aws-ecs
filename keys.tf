#-------------------------------------------------------------------------------
# ECS KEY PAIR
# Used by ECS instances to enable access via SSH
#-------------------------------------------------------------------------------
resource "aws_key_pair" "ecs" {
  count      = var.single_cluster_account ? 1 : 0
  key_name   = var.key_name
  public_key = file(var.key_file)

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [public_key]
  }
}

