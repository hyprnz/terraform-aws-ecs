# resource "null_resource" "enable_new_ecs_features" {
#   provisioner "local-exec" {
#     command = <<EOF
# aws ecs put-account-setting-default --name containerInstanceLongArnFormat --value enabled
# aws ecs put-account-setting-default --name serviceLongArnFormat --value enabled
# aws ecs put-account-setting-default --name taskLongArnFormat --value enabled
# EOF
#   }
# }