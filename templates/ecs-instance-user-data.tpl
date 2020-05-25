Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
yum install -y aws-cli
aws s3 cp s3://${s3_bucket_name}/ecs.config /etc/ecs/ecs.config

# Write the cluster configuration variable to the ecs.config file
# (add any other configuration variables here also)
echo ECS_INSTANCE_ATTRIBUTES={"\"lic.stack\"":"\"${lic_stack}\""} >> /etc/ecs/ecs.config

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
# Install awslogs and the jq JSON parser
yum install -y awslogs jq

# Inject the CloudWatch Logs configuration file contents
cat <<-EOF > /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = /var/log/dmesg
log_stream_name = {cluster}/{container_instance_id}

[/var/log/messages]
file = /var/log/messages
log_group_name = /var/log/messages
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %b %d %H:%M:%S

# SSH logs
[/var/log/secure]
file = /var/log/secure
log_group_name = /var/log/secure
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %b %d %H:%M:%S

# Cloud Init Logs (results of User Data Scripts)
[/var/log/cloud-init.log]
file = /var/log/cloud-init.log
log_group_name = /var/log/cloud-init.log
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %b %d %H:%M:%S

[/var/log/cloud-init-output.log]
file = /var/log/cloud-init-output.log
log_group_name = /var/log/cloud-init-output.log
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker.log
log_group_name = /var/log/docker
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log
log_group_name = /var/log/ecs/ecs-init.log
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = /var/log/ecs/ecs-agent.log
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = /var/log/ecs/audit.log
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

EOF

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
# Set the region to send CloudWatch Logs data to (the region where the container instance is located)
region=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')
sed -i -e "s/region = us-east-1/region = $region/g" /etc/awslogs/awscli.conf

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
cat <<-EOF > /usr/local/bin/cloudwatch-logs-starter.sh
	#!/bin/bash
	set -ex

	until curl -s http://localhost:51678/v1/metadata
	do
	  sleep 1
	done
	
	cluster=\$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .Cluster')
	container_instance_id=\$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print \$3}' )

	# Replace the cluster name and container instance ID placeholders with the actual values
	sed -i -e "s/{cluster}/\$cluster/g" /etc/awslogs/awslogs.conf
	sed -i -e "s/{container_instance_id}/\$container_instance_id/g" /etc/awslogs/awslogs.conf

	systemctl start awslogsd	
	systemctl enable awslogsd.service
EOF

chmod +x /usr/local/bin/cloudwatch-logs-starter.sh

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
cat <<-EOF > /etc/systemd/system/cloudwatch_logs_starter.service
[Unit]
Description=CloudWatch Log Starter
[Service]
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/cloudwatch-logs-starter.sh
EOF
systemctl enable cloudwatch_logs_starter
systemctl start cloudwatch_logs_starter
systemctl daemon-reload

aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/dmesg --retention-in-days 30
aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/messages --retention-in-days 30
aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/secure --retention-in-days 30
aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/cloud-init.log --retention-in-days 30
aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/cloud-init-output.log --retention-in-days 30
aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/docker --retention-in-days 30
aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/ecs/ecs-init.log --retention-in-days 30
aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/ecs/ecs-agent.log  --retention-in-days 30
aws --region ap-southeast-2 logs put-retention-policy --log-group-name /var/log/ecs/audit.log --retention-in-days 30

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
cat <<-EOF > /etc/rsyslog.d/30-docker.conf
# Log docker generated log messages to file
:syslogtag, isequal, "dockerd:" /var/log/docker.log

# comment out the following line to allow docker messages through.
# Doing so means you will also get docker messages in /var/log/syslog
& stop
EOF
systemctl restart rsyslog
systemctl restart docker

--==BOUNDARY==--
