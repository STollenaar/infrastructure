#!/bin/bash
# Set any ECS agent configuration options
cat <<EOF >>/etc/ecs/ecs.config
ECS_CLUSTER=${cluster_name}
ECS_LOGLEVEL=debug
ECS_ENABLE_TASK_IAM_ROLE=true
EOF
