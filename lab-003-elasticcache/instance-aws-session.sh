#!/bin/bash
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                   AWS ElastiCache Manager                    ║
║                    Port Forwarding Tool                       ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo -e "\n🔌 Port Forwarding Configuration\n"


echo "Select a profile:"

# List AWS profiles
mapfile -t PROFILES < <(aws configure list-profiles)

# Display profiles and allow selection
PS3="Choose a profile (enter number): "
select PROFILE in "${PROFILES[@]}"; do
    if [[ -n "$PROFILE" ]]; then
        echo "Selected profile: $PROFILE"
        break
    else
        echo "Invalid selection. Try again."
    fi
done

echo -e "\nFetching EC2 instances for profile: $PROFILE\n"

# List EC2 instances
mapfile -t INSTANCES < <(aws ec2 describe-instances \
                           --profile "$PROFILE" \
                           --filters "Name=tag:Name,Values=*bastion*" "Name=instance-state-name,Values=running" \
                           --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name]' \
                           --output text)

# Display instances and allow selection
PS3="Choose an EC2 instance (enter number): "
select INSTANCE in "${INSTANCES[@]}"; do
    if [[ -n "$INSTANCE" ]]; then
        INSTANCE_ID=$(echo "$INSTANCE" | awk '{print $1}')
        echo "Selected instance: $INSTANCE_ID"
        break
    else
        echo "Invalid selection. Try again."
    fi
done

echo -e "\nEstablishing port forwarding to ElastiCache Redis...\n"

aws ssm start-session \
    --target "$INSTANCE_ID" \
    --profile "$PROFILE" \
    --region sa-east-1
#    --document-name AWS-StartPortForwardingSession \
#    --parameters '{"portNumber":["6379"], "localPortNumber":["6379"]}'

